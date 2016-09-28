
import std.math;
import std.stdio;
import matrix;


alias Point = matrix.Vector!(3);
alias Vector = matrix.Vector!(3);

/// The unit of time in a single step operation
private enum double time_constant = 3.40885e-5;

/**************************************************************************
* Implements a structure representing a body (object) in the solar system.
*/ 
public struct solarBody
{
    /**************************************************************************
    * Define a new solar system body. The parameters defining the body have no
    * defined units but must be consistent within the solar system.
    *
    * Params:
    *    name     = The name of the body.
    *    mass     = The mass of the body.
    *    position = The initial position of the body_ within space.
    *    velocity = The initial velocity of the body_.
    */ 
    public this(string name, double mass, Point position, Vector velocity)
    {
        this.name_    = name;
        this.mass_    = mass;
        this.position = position;
        this.velocity = velocity;
        
        this.aceleration = [0.0, 0.0, 0.0];
    }
    
    @property string name() {return this.name_;}
    @property double mass() {return this.mass_;}
    
    @property double x() {return this.position[0];}
    @property double y() {return this.position[1];}
    @property double z() {return this.position[2];}
    
    @property double vx() {return this.velocity[0];}
    @property double vy() {return this.velocity[1];}
    @property double vz() {return this.velocity[2];}
    
    private
    {        
        /****
            * Reset the accumulated acceleration of the body_
            */
        void reset()
        {
            this.aceleration = [0.0, 0.0, 0.0];
        }
        
        /****
            * Compute the force (and there for the acceleration between two bodies
            *
            * Params:
            *     other = the other solar body action on this solar body (both bodies are affected).
            */
        void gforce(ref solarBody other)
        {
            auto delta = (this.position - other.position);
            auto d2 = delta^delta;
            
            auto force1 = this.mass*other.mass/d2;
            auto force = delta*(force1/sqrt(d2));
            
            this.aceleration  = this.aceleration  + force;
            other.aceleration = other.aceleration - force;
        }
        
        /****
            * Update the bodies velocity and position based of the forces applied to it
            */
        void move()
        {
            this.velocity = this.velocity - this.aceleration*(time_constant/this.mass);
            this.position = this.position + this.velocity*time_constant;
        }
        
        string name_;
        double mass_;
        Point  position;
        Vector velocity;
        Vector aceleration;
    }
}

public void solarTick(ref solarBody[] solarSystem)
{
    auto size = solarSystem.length;
    
    foreach (ref solarBody body_; solarSystem)
    {
        body_.reset();
    }
    
    for (int i = 0; (i < size); i++)
    {
        for (int j = i+1; (j < size); j++)
        {
            solarSystem[i].gforce(solarSystem[j]);
        }
    }
    
    foreach (ref solarBody body_; solarSystem)
    {
        body_.move();
    }
}