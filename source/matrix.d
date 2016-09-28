

import std.stdio;
import std.math;


/**************************************************************************
* This structure implements an N dimentional (mathematical) vector. All the
* standard vector opperations are implemented. The dot product uses the (A ^ B)
* notation since the convenional (A . B) notation accot be used.
*
* Params:
*     N = The dimention of the vector space (typically 2).
*     T = The element type of the vector (typically double)
*/
public struct Vector(uint N = 2, T = double)
{

    
    /**************************************************************************
    * Construct a Vector from a Vector of the same dimention.
    *
    * Params:
    *     other = The source Vector.
    */
    public this(ref const Vector!(N, T) other)
    {
        this.data = other.data.dup;
    }

    unittest
    {
        Vector!(3,int) a = [7, 8, 9];
        Vector!(3,int) tmp = a;
        
        a[0] = 1;
        a[1] = 1;
        a[2] = 1;
        
        assert(tmp[0] == 7);
        assert(tmp[1] == 8);
        assert(tmp[2] == 9);
    }

    /**************************************************************************
    * Construct a Vector from an array of the same dimention.
    *
    * Params:
    *     other = The source array.
    */
    public this(const T[] other)
    in
    {
        assert(other.length == N);
    }
    body
    {
        this.data = other.dup;
    }

    unittest
    {
        Vector!(int,3) tmp = [7, 8, 9];
        
        assert(tmp[0] == 7);
        assert(tmp[1] == 8);
        assert(tmp[2] == 9);
    }

    /**************************************************************************
    * Assign a Vector from an array of the same dimention.
    *
    * Params:
    *     other = The source array.
    */
    public void opAssign(const T[] other)
    in
    {
        assert(other.length == N);
    }
    body
    {
        this.data = other.dup;
    }

    unittest
    {
        Vector!(3,int) tmp;
        
        tmp = [7, 8, 9];
        
        assert(tmp[0] == 7);
        assert(tmp[1] == 8);
        assert(tmp[2] == 9);
    }

    /**************************************************************************
    * Assign a Vector from a Vector of the same dimention.
    *
    * Params:
    *     other = The source Vector.
    */
    public void opAssign(const Vector!(N,T) other)
    {
        this.data = other.data.dup;
    }

    unittest
    {
        Vector!(3,int) a = [7, 8, 9];
        Vector!(3,int) tmp;
        tmp = a;
        
        a[0] = 1;
        a[1] = 1;
        a[2] = 1;
        
        assert(tmp[0] == 7);
        assert(tmp[1] == 8);
        assert(tmp[2] == 9);
    }

    /**************************************************************************
    * Construct a Vector where all the elements have the same value.
    *
    * Params:
    *     other = The common value for all elements.
    *
    * Example:
    *     Vector!(double,3) origin = 0;  /// The origin or the vector space
    */
    public this(const T other)
    {
        for (auto i = 0; (i < data.length); i++)
        {
            this.data[i] = other;
        }
    }

    unittest
    {
        Vector!(3,int) tmp = 7;
        
        assert(tmp[0] == 7);
        assert(tmp[1] == 7);
        assert(tmp[2] == 7);
    }

    /// The dimention of the vector space
    public @property uint         length() {return N;}

    /// Duplicate the Vector. Modiyfing the new vector will not modify the original.
    public @property Vector!(N,T) dup()    {return Vector!(N,T)(this.data.dup);}

    /// A pointer to the data in memory.
    public @property T*           ptr()    {return this.data.ptr;}

    /// Index the elements of the Vector
    public ref T opIndex(size_t i) { return this.data[i]; }

    /// Assign to elements of the Vector
    public T opIndexAssign(T value, size_t i) {return this.data[i] = value;}

    unittest
    {
        Vector!(int,3) tmp;
        
        assert(tmp[0] == 0);
        assert(tmp[1] == 0);
        assert(tmp[2] == 0);
        
        tmp[0] = 7;
        tmp[1] = 8;
        tmp[2] = 9;
        
        assert(tmp[0] == 7);
        assert(tmp[1] == 8);
        assert(tmp[2] == 9);
    }

    static if (false)
    {
        /**************************************************************************
        * Implements the vector offset (a += b and a -= b) and cross product (a *= b).
        *
        * Params:
        *     rhs = The right hand side of the operation (a vector).
        *
        * Retuns:
        *     This
        */
        public Vector!(N,T) opAssign(string op)(const Vector!(N,T) rhs)
            if (op != "^")
        {
            static if (op == "+")
            {
                for (auto i = 0; (i < data.length); i++)
                {
                this.data[i] += rhs.data[i];
                }
            }
            else static if (op == "-")
            {
                for (auto i = 0; (i < data.length); i++)
                {
                this.data[i] -= rhs.data[i];
                }
            }
            else static if (op == "*")
            {
                // Cross product
                T[N] tmp;
                for (auto i = 0; (i < data.length); i++)
                {
                tmp[i] = (this.data[(i+1)%N] * rhs.data[(i+2)%N]) - (this.data[(i+N-1)%N] * rhs.data[(i+N-2)%N]);
                }
                this.data = tmp;
            }
            
            return this;
        }
        
        unittest
        {
            Vector!(3,int) tmp1 = [1,2,3];
            Vector!(3,int) tmp2 = [7,8,9];
            
            tmp2 += tmp1;
            
            assert(tmp2[0] ==  8);
            assert(tmp2[1] == 10);
            assert(tmp2[2] == 12);
            
            tmp2 = [7,8,9];
            
            tmp2 -= tmp1;
            
            assert(tmp2[0] == 6);
            assert(tmp2[1] == 6);
            assert(tmp2[2] == 6);
            
            tmp2 = [7,8,9];
            
            tmp2 *= tmp1;
            
            assert(tmp2[0] ==   6);
            assert(tmp2[1] == -12);
            assert(tmp2[2] ==   6);
        }
        
        
        
        /**************************************************************************
        * Implements the vector scaling operations (a *= b and a /= b).
        *
        * Params:
        *     rhs = The scaling factor.
        *
        * Retuns:
        *     This
        */
        public Vector!(N,T) opAssign(string op)(T rhs)
        {
            static if (op == "*")
            {
                for (auto i = 0; (i < data.length); i++)
                {
                this.data[i] *= rhs;
                }
            }
            else static if (op == "/")
            {
                for (auto i = 0; (i < data.length); i++)
                {
                this.data[i] /= rhs;
                }
            }
            
            return this;
        }
        
        
        unittest
        {
            Vector!(3,int) tmp2 = [7,8,9];
            
            tmp2 *= 2;
            
            assert(tmp2[0] == 14);
            assert(tmp2[1] == 16);
            assert(tmp2[2] == 18);
            
            tmp2 = [7,8,9];
            
            tmp2 /= 2;
            
            assert(tmp2[0] == 3);
            assert(tmp2[1] == 4);
            assert(tmp2[2] == 4);
        }
    }

    /**************************************************************************
    * Implements the vector offset (a = b + c and a = b - c) and cross product (a = b * c).
    *
    * Params:
    *     rhs = The right hand side of the operation (a vector).
    *
    * Returns:
    *     The Vector result.
    */
    public Vector!(N,T) opBinary(string op)(Vector!(N,T) rhs)
        if (op != "^")
    {
        Vector!(N,T) rtn;
            
        static if (op == "+")
        {
            for (auto i = 0; (i < N); i++)
            {
                rtn.data[i] = this.data[i] + rhs.data[i];
            }
        }
        else static if (op == "-")
        {
            for (auto i = 0; (i < N); i++)
            {
                rtn.data[i] = this.data[i] - rhs.data[i];
            }
        }
        else static if (op == "*")
        {
            // Cross product
            for (auto i = 0; (i < N); i++)
            {
                rtn.data[i] = (this.data[(i+1)%N] * rhs.data[(i+2)%N]) - (this.data[(i+N-1)%N] * rhs.data[(i+N-2)%N]);
            }
        }
            
        return rtn;
    }


    unittest
    {
        Vector!(3,int) tmp1 = [1,2,3];
        Vector!(3,int) tmp2 = [7,8,9];
        Vector!(3,int) tmp3;
        
        tmp3 = tmp2 + tmp1;
        
        assert(tmp3[0] ==  8);
        assert(tmp3[1] == 10);
        assert(tmp3[2] == 12);
        
        tmp3 = tmp2 - tmp1;
        
        assert(tmp3[0] == 6);
        assert(tmp3[1] == 6);
        assert(tmp3[2] == 6);
        
        tmp3 = tmp2 * tmp1;
        
        assert(tmp3[0] ==   6);
        assert(tmp3[1] == -12);
        assert(tmp3[2] ==   6);
        
        Vector!(3,int) tmp4 = [1,0,0];
        Vector!(3,int) tmp5 = [0,1,0];
        Vector!(3,int) tmp6 = [0,0,1];
        
        assert((tmp4 * tmp5) == tmp6);
        assert((tmp5 * tmp6) == tmp4);
        assert((tmp6 * tmp4) == tmp5);
        assert((tmp4 * tmp6) == (tmp5*-1));
    }

    /**************************************************************************
    * Implements the vector dot product (a = b ^ c).
    *
    * Params:
    *     rhs = The right hand side of the operation (a vector).
    *
    * Returns:
    *     The scalar dot product result.
    */
    public T opBinary(string op)(Vector!(N,T) rhs)
        if (op == "^")
    {
        T rtn = 0;
        
        for (auto i = 0; (i < N); i++)
        {
            rtn += this.data[i] * rhs.data[i];
        }
            
        return rtn;
    }

    unittest
    {
        Vector!(3,int) tmp1 = [7,8,9];
        Vector!(3,int) tmp2 = [1,2,3];
        
        assert((tmp1 ^ tmp2) ==  50);
        assert((tmp1 ^ tmp1) == 194);
        assert((tmp2 ^ tmp2) ==  14);
        
        Vector!(3,int) tmp3 = [1,0,0];
        Vector!(3,int) tmp4 = [0,1,0];
        Vector!(3,int tmp5 = [0,0,1];
        
        assert((tmp3 ^ tmp4) == 0);
        assert((tmp4 ^ tmp5) == 0);
        assert((tmp5 ^ tmp3) == 0);
    }

    /**************************************************************************
    * Implements the vector scaling operations (a = b * c and a = b / c).
    *
    * Params:
    *     rhs = The scaling factor.
    *
    * Returns:
    *     The Vector result.
    */
        public Vector!(N,T) opBinary(string op)(T rhs)
    {
        Vector!(N,T) rtn;
            
        static if (op == "*")
        {
            for (auto i = 0; (i < N); i++)
            {
                rtn.data[i] = this.data[i] * rhs;
            }
        }
        else static if (op == "/")
        {
            for (auto i = 0; (i < N); i++)
            {
                rtn.data[i] = this.data[i] / rhs;
            }
        }
            
        return rtn;
    }


    unittest
    {
        Vector!(3,int) tmp1 = [7,8,9];
        Vector!(3,int) tmp2;
        
        tmp2 = tmp1 * 2;
        
        assert(tmp2[0] == 14);
        assert(tmp2[1] == 16);
        assert(tmp2[2] == 18);
        
        tmp2 = tmp1 / 2;
        
        assert(tmp2[0] == 3);
        assert(tmp2[1] == 4);
        assert(tmp2[2] == 4);
    }

    private T[N] data;
}

public struct matrix(T, uint X, uint Y)
{
// TODO

//private T[X , Y] data;
}
