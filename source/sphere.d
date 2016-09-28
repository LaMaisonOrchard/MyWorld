import std.stdio;
import std.string;

import derelict.sdl2.sdl;
import derelict.opengl3.gl3;
import derelict.util.exception;



public struct Vertex
{
    float x;
    float y;
    float z;
}

public class Sphere
{
    public this()
    {
        // Create the Vertex Array Object
        GLuint vertexArrayID;
        glGenVertexArrays(1, &vertexArrayID);
        glBindVertexArray(vertexArrayID);

        // XYZ coordinates of vertices of our triangle
        auto vertices =
        [
            Vertex(-1, -1, 0), Vertex(1, -1, 0), Vertex(0, 1, 0),
        ];
        
        // Create a new vertex buffer and write its ID into vertexBufferID
        glGenBuffers(1, &this.vertexBufferID);
        // The following vertex buffer calls will work with the buffer specified by
        // vertexBufferID
        glBindBuffer(GL_ARRAY_BUFFER, this.vertexBufferID);
        // Copy vertices into the vertex buffer.
        // Usually the means "copy to the VRAM"
        glBufferData(GL_ARRAY_BUFFER,
                    vertices.length * Vertex.sizeof,
                    vertices.ptr,
                    GL_STATIC_DRAW);        
    }
    
    public void draw(GLuint programID)
    {
        // Use the first slot for a vertex attribute array
        glEnableVertexAttribArray(0);
        glBindBuffer(GL_ARRAY_BUFFER, this.vertexBufferID);
        // Tell GL where the vertex attribute is
        glVertexAttribPointer(
            0,            // We're using attribute 0
            3,            // Number of coordinates (we have 3D vertices, so 3)
            GL_FLOAT,     // Type of coordinates (float)
            GL_FALSE,
            0,
            cast(void*)0  // Start at the beginning (0) of the vertex buffer
        );

        // Draw. Sorta. 3 vertices starting from index 0.
        glUseProgram(programID);
        glDrawArrays(GL_TRIANGLES, 0, 3);
    }

    protected GLuint vertexBufferID;
}

public class Sun
{
    public this()
    {
        // Create the drawing programs /////////////////////////
        string vertexShaderSrc =
            q{
                #version 330 core
                layout(location = 0) in vec3 inVertexPosition;
                void main()
                {
                    gl_Position = vec4(inVertexPosition, 1.0);
                }
            };
        string fragmentShaderSrc =
            q{
                #version 330 core
                out vec3 color;
                void main()
                {
                    color = vec3(1,1,0);
                }
            };
        this.programID = compileShaders(vertexShaderSrc, fragmentShaderSrc);
        
        this,shape = new Sphere();
    }
    
    public void draw()
    {
        this.shape.draw(this.programID);
    }

    private GLuint programID;
    private Sphere shape;
}

public class Planet
{
    public this()
    {
        // Create the drawing programs /////////////////////////
        string vertexShaderSrc =
            q{
                #version 330 core
                layout(location = 0) in vec3 inVertexPosition;
                void main()
                {
                    gl_Position = vec4(inVertexPosition/2, 1.0);
                }
            };
        string fragmentShaderSrc =
            q{
                #version 330 core
                out vec3 color;
                void main()
                {
                    color = vec3(1,1,1);
                }
            };
        this.programID = compileShaders(vertexShaderSrc, fragmentShaderSrc);
        
        this,shape = new Sphere();
    }
    
    public void draw()
    {
        this.shape.draw(this.programID);
    }

    private GLuint programID;
    private Sphere shape;
}


private GLuint compileShaders(string vertexSrc, string fragmentSrc)
{
    // Create the shaders
    GLuint vertexShaderID = glCreateShader(GL_VERTEX_SHADER);
    GLuint fragmentShaderID = glCreateShader(GL_FRAGMENT_SHADER);

    // Compile the vertex shader
    writeln("we're about to attempt compiling a vertex shader");
    auto vertexZeroTerminated = toStringz(vertexSrc);
    glShaderSource(vertexShaderID, 1, &vertexZeroTerminated, null);
    glCompileShader(vertexShaderID);

    // Use this to determine how much to allocate if infoLog is too short
    // glGetShaderiv(vertexShaderID, GL_INFO_LOG_LENGTH, &infoLogLength);

    // Check for errors
    GLint compiled;
    glGetShaderiv(vertexShaderID, GL_COMPILE_STATUS, &compiled);
    char[1024 * 8] infoLog;
    glGetShaderInfoLog(vertexShaderID, infoLog.length, null, infoLog.ptr);
    import core.stdc.stdio;
    writeln("vertex shader info log:");
    puts(infoLog.ptr);
    if(!compiled)
    {
        throw new Exception("Failed to compile vertex shader " ~ vertexSrc);
    }

    // Compile Fragment Shader
    writeln("we're about to attempt compiling a fragment shader");
    auto fragmentZeroTerminated = toStringz(fragmentSrc);
    glShaderSource(fragmentShaderID, 1, &fragmentZeroTerminated, null);
    glCompileShader(fragmentShaderID);

    // Check for errors
    glGetShaderiv(fragmentShaderID, GL_COMPILE_STATUS, &compiled);
    glGetShaderInfoLog(fragmentShaderID, infoLog.length, null, infoLog.ptr);
    writeln("fragment shader info log:");
    puts(infoLog.ptr);
    if(!compiled)
    {
        throw new Exception("Failed to compile fragment shader " ~ fragmentSrc);
    }

    // Link the program
    writeln("we're about to attempt linking");
    GLuint programID = glCreateProgram();
    glAttachShader(programID, vertexShaderID);
    glAttachShader(programID, fragmentShaderID);
    glLinkProgram(programID);

    // Check the program
    GLint linked;
    glGetProgramiv(programID, GL_LINK_STATUS, &linked);
    glGetProgramInfoLog(programID, infoLog.length, null, infoLog.ptr);
    writeln("linking info log:");
    puts(infoLog.ptr);
    if(!linked)
    {
        throw new Exception("Failed to link shaders " ~ vertexSrc ~ " " ~ fragmentSrc);
    }

    glDeleteShader(vertexShaderID);
    glDeleteShader(fragmentShaderID);

    return programID;
}