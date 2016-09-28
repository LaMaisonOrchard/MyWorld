

import std.json;
import std.stdio;
import std.file;
import std.path;
import std.process;
import solar;

static this()
{
    Settings.init("MyWorld");
}

static ~this()
{
    Settings.close("MyWorld");
}

double getFloat(JSONValue value)
{
    switch(value.type)
    {
        case JSON_TYPE.STRING:
            return 0.0;

        case JSON_TYPE.INTEGER:
            return cast(double)value.integer;

        case JSON_TYPE.UINTEGER:
            return cast(double)value.uinteger;

        case JSON_TYPE.FLOAT:
            return value.floating;
        
        case JSON_TYPE.NULL:
        case JSON_TYPE.OBJECT:
        case JSON_TYPE.ARRAY:
        case JSON_TYPE.TRUE:
        case JSON_TYPE.FALSE:
        default:
            throw new JSONException("Value not numeric");
    }
}


public struct Settings
{
    public
    {
        /************************************************************************
         * Get the current solar system state.
         *
         * Returns:
         *    The current simulation time in minute since the epoc
         */
        static uint getSolarSystem(ref solarBody[] solarSystem)
        {
            solarSystem = this.solarSystem.dup;
            
            return this.time;
        }
        
        /************************************************************************
         * Set the current solar system state.
         *
         */
        static void setSolarSystem(uint time, solarBody[] solarSystem)
        {
            this.time        = time;
            this.solarSystem = solarSystem.dup;
        }
    }
    
    unittest
    {
        writeln(this.settings.type);
        assert(this.settings.type == JSON_TYPE.OBJECT);
        assert(this.settings["SimTime"].type == JSON_TYPE.INTEGER);
        solarBody[] SolarSystem;
        assert(getSolarSystem(SolarSystem) == 100);
    }
    
    
    private
    {
        static void init(string name)
        {
            JSONValue settings;
            
            // Set the application driectory relative to the users home directory
            rootDir  = buildPath(environment["HOME"], "MyWorld");
            
            // Get the name of the settings file
            name = rootDir ~ "/" ~ name ~ ".json";
            
            writeln("In");
            if (!exists(rootDir))
            {
                mkdirRecurse(rootDir);
            }
            else if (!exists(name) || !attrIsFile(getAttributes(name)))
            {
                string def = 
                "{\n"
                    "\"Version\" : 1,\n"
                    "\"SimTime\" : 1051200000,\n"
                    "\"SolarSystem\" : \n["
                        "{\"Name\": \"xray\" , \"Mass\": 100.0 , \"Posn\" : [ 1000.0, 0.0, 0.0] , \"Velocity\" : [ 0.0, 1000.0, 0.0] },\n"
                        "{\"Name\": \"lumus\" , \"Mass\": 1000000000.0 , \"Posn\" : [ 0.0, 0.0, 0.0] , \"Velocity\" : [ 0.0, 0.0, 0.0] }\n"
                    "]\n"
                "}";
                
                
                settings = parseJSON(def);
            }
            else
            {
                writeln("Read");
                settings = parseJSON(readText(name));
            }
            
            this.time = cast(uint)settings["SimTime"].integer;
            
            // Clear the list
            this.solarSystem.length = 0;
            auto list = settings["SolarSystem"].array;
            foreach (JSONValue body_; list)
            {
                writeln(body_["Name"].str);
                this.solarSystem ~= solarBody
                (
                    body_["Name"].str,
                    getFloat(body_["Mass"]),
                    Point([getFloat(body_["Posn"][0]), getFloat(body_["Posn"][1]), getFloat(body_["Posn"][2])]),
                    Vector([getFloat(body_["Velocity"][0]), getFloat(body_["Velocity"][1]), getFloat(body_["Velocity"][2])])
                );
            }
        }
        
        static void close(string name)
        {
            JSONValue settings = ["Version": 1];
        
            // Get the name of the settings file
            name = rootDir ~ "/" ~ name ~ ".json";
            
            settings.object["SimTime"]     = JSONValue(this.time);
            
            JSONValue[] list;
            foreach (solarBody body_; this.solarSystem)
            {
                JSONValue newBody = ["Name": body_.name];
                
                newBody["Mass"]     = JSONValue( body_.mass);
                newBody["Posn"]     = JSONValue([body_.x,  body_.y,  body_.z]);
                newBody["Velocity"] = JSONValue([body_.vx, body_.vy, body_.vz]);
                
                list ~= newBody;
            }
            
            settings.object["SolarSystem"] = JSONValue(list);
            
            writeln("Out");
            std.file.write(name, toJSON(&settings, true));
        }
        
        static string rootDir = ".";   
        
        static uint time;
        static solarBody[] solarSystem;
    }
}