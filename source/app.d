import std.stdio;
import std.string;
import std.datetime;

import solar;
import settings;
import sphere;

import derelict.sdl2.sdl;
import derelict.opengl3.gl3;
import derelict.util.exception;

version(linux)
{
    pragma(lib, "dl");
}

void main()
{
    //orbit();
    //sim();
    gui();
}


int gui()
{
    // Load SDL2 and GL. ///////////////////////////////////////////////////
    try
    {
        // Load the SDL 2 library.
        DerelictSDL2.load();

        // Load the SDL2_image library.
        //DerelictSDL2Image.load();

        // Load the SDL2_mixer library.
        //DerelictSDL2Mixer.load();

        // Load the SDL2_ttf library
        //DerelictSDL2ttf.load();

        // Load the SDL2_net library.
        //DerelictSDL2Net.load();
        
        DerelictGL3.load();
    }
    // Print errors, if any.
    catch(SharedLibLoadException e)
    {
        writeln("SDL2 or GL not found: " ~ e.msg);
    }
    catch(SymbolLoadException e)
    {
        writeln("Missing SDL2 or GL symbol (old version installed?): " ~ e.msg);
    }

    // When done, unload the libraries.
    scope(exit)
    {
        //DerelictGL3.unload();
        DerelictSDL2.unload();
    }
    
    // Initialize SDL Video subsystem. //////////////////////////////////////
    if(SDL_Init(SDL_INIT_VIDEO) < 0)
    {
        // SDL_Init returns a negative number on error.
        writeln("SDL Video subsystem failed to initialize");
        return 1;
    }
    // Deinitialize SDL at exit.
    scope(exit)
    {
        SDL_Quit();
    }
    
    
    // Create a window //////////////////////////////////////////////////////
    // OpenGL 3.2 core profile.
    // and the core profile (i.e. no deprecated functions)
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 3);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 2);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE);

    // 32bit RGBA window
    SDL_GL_SetAttribute(SDL_GL_RED_SIZE,     8);
    SDL_GL_SetAttribute(SDL_GL_GREEN_SIZE,   8);
    SDL_GL_SetAttribute(SDL_GL_BLUE_SIZE,    8);
    SDL_GL_SetAttribute(SDL_GL_ALPHA_SIZE,   8);
    // Double buffering to avoid tearing
    SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);
    // Depth buffer. Not useful when drawing a triangle, but almost always
    // useful when drawing 3D
    SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE,   24);
    

    // Create a centered 640x480 OpenGL window named "Triangle"
    SDL_Window* window = SDL_CreateWindow("Triangle",
                                        SDL_WINDOWPOS_CENTERED,
                                        SDL_WINDOWPOS_CENTERED,
                                        640, 480,
                                        SDL_WINDOW_OPENGL | SDL_WINDOW_SHOWN);
    // Exit if window creation fails.
    if(null is window)
    {
        writeln("Failed to create the application window : " ~ fromStringz(SDL_GetError()).idup);
        return 1;
    }

    // Destroy the window at exit.
    scope(exit)
    {
        SDL_DestroyWindow(window);
    }
    
    // Create an OpenGL context for our window. //////////////////////////////
    SDL_GLContext context = SDL_GL_CreateContext(window);
    // Delete the GL context when we're done.
    scope(exit)
    {
        SDL_GL_DeleteContext(context);
    }
    // Load all OpenGL functions and extensions supported by Derelict.
    DerelictGL3.reload();
    
    

    frame(window);
    
    return 0;
}

bool frame(SDL_Window* window)
{
    enum uint frameRate = 80;
    
    // Get the simulated solar system
    solarBody[] solarSystem;
    uint time = Settings.getSolarSystem(solarSystem);
    
    auto sun  = new Sun();
    auto xray = new Planet();
    
    
    // Syncronise real and simulation time
    long realTime = Clock.currStdTime();
    while ((realTime/(60*10_000_000)) > time)
    {
        while ((realTime/(60*10_000_000)) > time)
        {
            solarTick(solarSystem); time += 1;
        }
        realTime = Clock.currStdTime();
    }
    
    bool exit = false;
    while(!exit)
    {
        uint count = 0;
        uint frameCount = 0; 
        while ((frameCount < frameRate) && !exit)
        {
            // Process GUI events ///////////////////////////////////////////////
            // Read all waiting events
            SDL_Event e;
            while(SDL_PollEvent(&e) != 0)
            {
                // Quit if the user closes the window or presses Q
                if(e.type == SDL_QUIT)
                {
                    exit = true;
                }
                else if(e.type == SDL_KEYDOWN)
                {
                    //Select surfaces based on key press
                    switch(e.key.keysym.sym)
                    {
                        case SDLK_q:
                            exit = true;
                            break;
                            
                        default:
                            break;
                    }
                }
            }

            // Render the display ////////////////////////////////////////////////
            // Clear the back buffer with a red background (parameters are R, G, B, A)
            glClearColor(0.0, 0.0, 0.0, 1.0);
            glClear(GL_COLOR_BUFFER_BIT);
            
            sun.draw();
            xray.draw();    
            
            // Swap the back buffer to the front, showing it in the window.
            SDL_GL_SwapWindow(window);
            
            // Reglate the time //////////////////////////////////////////////////
            auto now = Clock.currStdTime();
            while (realTime < now) {realTime += (10_000_000/frameRate); frameCount += 1;}
            SDL_Delay(cast(uint)((realTime-now)/10_000));
            
            count += 1;
        }
        
        // Report the frame rate
        writeln(count);
        
        // Tick the solar system
        while ((realTime/(60*10_000_000)) > time)
        {
            solarTick(solarSystem); time += 1;
        }
    }
    
    Settings.setSolarSystem(time, solarSystem);
    
    return exit;
}



void sim()
{
    
    solarBody[] solarSystem;
    uint time = Settings.getSolarSystem(solarSystem);
    
    uint years = 0;
    uint count = 0;
    auto prev  = (solarSystem[1].y < 0.0);
    auto next  = (solarSystem[1].y < 0.0);
    
    while (years < 100)
    {
        prev = next;
        
        solarTick(solarSystem); time += 1; count += 1;
        
        next = (solarSystem[0].y < 0.0);
        
        if (prev && !next)
        {
            writeln("ping");
            years += 1;
        }
    }
    
    writeln((cast(double)count)/cast(double)years);
    
    Settings.setSolarSystem(time, solarSystem);
}

void orbit()
{
    solarBody[] solarSystem =
    [
        // stable velocity = sqrt(force*radius/mass)
         solarBody("sun",  1000_000_000.0, Point(0.0),           Vector(0.0))
        ,solarBody("xray",    100.0, Point([1000.0,0.0,0.0]), Vector([0.0,1000.0,0.0]))
    ];
    
    uint count = 0;
    auto prev  = (solarSystem[1].y < 0.0);
    auto next  = (solarSystem[1].y < 0.0);
    
    while (!(prev && !next))
    {
        prev = next;
        
        count += 1;
        solarTick(solarSystem);
        writeln("Posn = ", solarSystem[1].x, ",", solarSystem[1].y, ",", solarSystem[1].z);
        
        next = (solarSystem[1].y < 0.0);
    }
    
    // Target orbit = 184320 = 128days * 24hours * 60 minutes
    writeln("Orbit = ", count);
}
