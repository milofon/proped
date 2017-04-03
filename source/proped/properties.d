/**
 * The module contains the objects and the properties of control functions
 *
 * Copyright: (c) 2015-2016, Milofon Project.
 * License: Subject to the terms of the BSD license, as written in the included LICENSE.txt file.
 * Authors: Maksim Galanin
 */
module proped.properties;

private
{
    import std.typecons : NullableRef, Nullable;
    import std.array : split, empty;
    import std.meta : staticIndexOf, AliasSeq;
    import std.conv : to;
    static import std.traits;

    import proped.uninode;
    import proped.exception;
}

alias Types = AliasSeq!(bool, int, long, double, string);
alias PropNode = UniNode!(Types);


enum DELIMITER_CHAR = '.';
enum DEFAULT_FIELD_NAME = "v";


template IsValidType(T)
{
    enum IsValidType = staticIndexOf!(T, Types) >= 0 
        || (std.traits.isArray!T && is(std.traits.ForeachType!T == PropNode))
        || (std.traits.isAssociativeArray!T && is(std.traits.KeyType!T == string) && is(std.traits.ValueType!T == PropNode));
}


/**
 * Class contains methods to manage the properties
 */
struct Properties
{
    private PropNode head;


    this(T)(T val) if (IsValidType!T)
    {
        head = PropNode(val);
    }


    this(PropNode node)
    {
        head = node;
    }


    /**
     * Getting node in the specified path
     *
     * It the node is an object, the we try to find the embedded objects in the specified path
     *
     * Params:
     *
     * path = The path to the desired site
     */
    private NullableRef!PropNode findNode(string path)
    {
        auto names = path.split(DELIMITER_CHAR);

        NullableRef!PropNode findPath(PropNode* node, string[] names)
        {
            if(names.length == 0)
                return NullableRef!PropNode(node);

            string name = names[0];
            if ((*node).isObject)
                if (auto chd = name in (*node).toObject)
                    return findPath(chd, names[1..$]);

            return NullableRef!PropNode.init;
        }

        if (names.length > 0)
            return findPath(&head, names);

        return NullableRef!PropNode.init;
    }


    /**
     * Checking for the presence of the node in the specified path
     *
     * It the node is an object, the we try to find the embedded objects in the specified path
     *
     * Params:
     *
     * path = The path to the desired site
     */
    bool opBinaryRight(string op)(string path) if ("in" == op)
    {
        auto node = findNode(path);
        return !node.isNull;
    }


    /**
     * Returns the length of an object
     */
    ulong length() @property
    {
        if (head.isArray)
            return head.toArray().length;
        else if (head.isObject)
            return head.toObject().length;
        else if (typeid(string) == head.type)
            return head.length;
        return 0;
    }


    alias opDollar = length;


    /**
     * Get the node if the specified path is not a node
     *
     * Params:
     *
     * path = The path to the desired site
     *
     * Example:
     * ---
     * node.get!int("foo.bar");
     * ---
     */
    Nullable!T get(T)(string path) if (IsValidType!T)
    {
        return doGet!T(findNode(path));
    }


    /**
     * Get the value of the node
     *
     * Example
     * ---
     * node.get!int;
     * ---
     */
    Nullable!T get(T)() if (IsValidType!T)
    {
        return doGet!T(NullableRef!PropNode(&head));
    }


    private Nullable!T doGet(T)(NullableRef!PropNode node)
    {
        if (!node.isNull)
        {
            if (node.get.convertsTo!T)
                return Nullable!T(node.get.get!T);
            else
                return Nullable!T.init;
        }
        else
            return Nullable!T.init;
    }


    /**
     * Get the value, otherwise return the default value
     *
     * Params:
     *
     * alt = Default value
     *
     * Example:
     * ---
     * getOrElse(1);
     * ---
     */
    T getOrElse(T)(T alt) if (IsValidType!T)
    {   
        return doGetOrElse!T(NullableRef!PropNode(&head), alt);
    }


    /**
     * Get the node at the specified path, or return to the default value
     *
     * Params:
     *
     * path = The path to the desired site
     * alt  = Default value
     *
     * Example:
     * ---
     * getOrElse("foo", 1);
     * ---
     */
    T getOrElse(T)(string path, T alt) if (IsValidType!T)
    {   
        return doGetOrElse!T(findNode(path), alt);
    }


    private T doGetOrElse(T)(NullableRef!PropNode node, T alt) if (IsValidType!T)
    {
        if (!node.isNull)
        {
            if (node.get.convertsTo!T)
                return node.get.get!T;
            else
                return alt;
        }
        else
            return alt;
    }


    /**
     * Check type node
     */
    bool isType(T)()
    {
        return head.type == typeid(T);
    }


    /** 
     * Get an array of properties on the specified path
     *
     * Params:
     *
     * path = The path to the desired site
     *
     * Example:
     * ---
     * getArray("services");
     * ---
     */
    Properties[] getArray(string path)
    {
        return doGetArray(findNode(path));
    }


    /**
     * Get an array of properties on the node
     *
     * Example
     * ---
     * node.getArray();
     * ---
     */
    Properties[] getArray()
    {
        return doGetArray(NullableRef!PropNode(&head));
    }


    private Properties[] doGetArray(NullableRef!PropNode nodeRef)
    {
        Properties[] result;

        if (nodeRef.isNull)
            return result;

        PropNode node = nodeRef.get; 

        if (!node.isArray)
        {
            result ~= Properties(node); 
        }
        else
        {
            foreach(PropNode ch; node.get!(PropNode[]))
            {
                result ~= Properties(ch); 
            }
        }
        return result;
    }


    /** 
     * Get an associative array of object properties in the specified path
     *
     * Params:
     *
     * path = The path to the desired site
     *
     * Example:
     * ---
     * getObject("services");
     * ---
     */
    Properties[string] getObject(string path)
    {
        return doGetObject(findNode(path));
    }


    /** 
     * Get an associative array of object properties in the node
     *
     * Params:
     *
     * path = The path to the desired site
     *
     * Example:
     * ---
     * getObject();
     * ---
     */
    Properties[string] getObject()
    {
        return doGetObject(NullableRef!PropNode(&head));
    }


    private Properties[string] doGetObject(NullableRef!PropNode nodeRef)
    {
        Properties[string] result;

        if (nodeRef.isNull)
            return result;

        PropNode node = nodeRef.get;
        if (!node.isObject)
        {
            result[DEFAULT_FIELD_NAME] = Properties(node);
        }
        else
        {
            foreach(string k, PropNode ch; node.get!(PropNode[string]))
                result[k] = Properties(ch); 
        }

        return result;
    }


    /**
     * The string representation
     */
    string toString()
    {
        return head.toString();
    }


    /**
     * Recursive merge properties
     *
     * When the merger is not going to existing nodes
     * If the parameter is an array, it will their concatenation
     *
     * Params:
     *
     * src = Source properties
     */
    Properties opOpAssign(string op)(Properties src) if ("~" == op)
    {
        if (src.head.hasNull)
            return this;

        if (head.hasNull)
        {
            head = src.head;
            return this;
        }

        void mergeNode(ref PropNode dst, ref PropNode src)
        {
            if (dst.isObject && src.isObject)
            {
                auto dstMap = dst.toObject;
                foreach(string k, PropNode ch; src.toObject)
                {
                    if (auto tg = k in dstMap)
                        mergeNode(*tg, ch);
                    else
                        dstMap[k] = ch;
                }
            }
            else if (dst.isArray)
            {
                auto dstArr = dst.toArray;
                dst = dstArr ~ src;
            }
        }

        mergeNode(head, src.head);
        return this;
    }


    /**
     * Get a subset of properties in the specified path
     *
     * Params:
     *
     * path = The path to the desired site
     */
    Nullable!Properties sub(string path)
    {
        auto node = findNode(path);
        return node.isNull ? Nullable!Properties.init : Nullable!Properties(Properties(node.get));
    }


    /**
     * Finding and installing a new value in the specified path
     *
     * If the specified path object will be the object or an array, it will be thrown
     * Also, when a situation of lack of necessaty way, a new item will be created
     *
     * Params:
     *
     * path = The path to the desired site
     * val  = New value
     */
    void set(T)(string path, T val) if (IsValidType!T)
    {
        set(path, PropNode(val));
    }


    /**
     * Finding and installing a new value in the specified path
     *
     * If the specified path object will be the object or an array, it will be thrown
     * Also, when a situation of lack of necessaty way, a new item will be created
     *
     * Params:
     *
     * path = The path to the desired site
     * val  = New value
     */
    void set(string path, PropNode val)
    {
        auto names = path.split(DELIMITER_CHAR);

        PropNode createPath(PropNode terminal, string[] names)
        {
            if (names.empty)
                return terminal;

            PropNode[string] map;
            map[names[0]] = createPath(terminal, names[1..$]);
            return PropNode(map);
        }

        void setNode(ref PropNode node, string[] names)
        {
            if (names.empty)
            {
                if (node.isObject || node.isArray)
                    throw new PropertiesException("The node '" ~ path ~ "' is not a simple type");
                node = val;
                return;
            }

            string name = names[0];
            if (node.isObject)
            {
                if (auto chd = name in node.toObject)
                    setNode(*chd, names[1..$]);
                else
                {
                    PropNode newNode = createPath(val, names[1..$]);
                    if (node.length == 0)
                    {
                        PropNode[string] map;
                        map[name] = newNode;
                        node = map;
                    }
                    else
                        node.toObject[name] = newNode;
                }
            }
            else
                throw new PropertiesException("Failed to set values for the key. The parent node for '" ~ name ~ "' is not object");
        }

        setNode(head, names);
    }


    /**
     * Installing a new value in the node
     *
     * Params:
     *
     * val  = New value
     */
    void set(T)(T val) if (IsValidType!T)
    {
        if (node.isObject || node.isArray)
            throw new PropertiesException("The node '" ~ path ~ "' is not a simple type");
        head = val;
    }


    /**
     * Check property is object
     */
    bool isObject() @property
    {
        return head.isObject;
    }

    
    /**
     * Check property is array
     */
    bool isArray() @property
    {
        return head.isArray;
    }
}

