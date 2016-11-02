/**
 * The module implements a universal structure UniNode and functions to work with it
 *
 * Copyright: (c) 2015-2016, Milofon Project.
 * License: Subject to the terms of the BSD license, as written in the included LICENSE.txt file.
 * Authors: Maksim Galanin
 */

module proped.uninode;

private
{
    import std.typecons: Nullable;
    import std.variant: Algebraic, This, VariantN;
}


/**
 * The data type allows you to save a specified type that implements the mechanisms nesting
 */
alias UniNode(Types...) = Algebraic!(Types, This[], This[string]); 


/**
 * Check the type of the array of embedded objects of universal content object
 */
@property bool isArray(T : VariantN!(tsize, Types), size_t tsize, Types...)(T node)
{
    return typeid(T[]) == node.type;
}   


/**
 * Check the type of associative array contents generic object
 */
@property bool isObject(T : VariantN!(tsize, Types), size_t tsize, Types...)(T node)
{
    return typeid(T[string]) == node.type;
}   


/**
 * Check for zero content
 */
@property bool hasNull(T : VariantN!(tsize, Types), size_t tsize, Types...)(T node)
{
    return !node.hasValue;
}   


/**
 * Converting generic object into an associative array
 */
T[string] toObject(T : VariantN!(tsize, Types), size_t tsize, Types...)(T node)
{
    if (node.isObject)
        return node.get!(T[string]);
    return null;
}


/**
 * Converting a universal object in the array
 */
T[] toArray(T : VariantN!(tsize, Types), size_t tsize, Types...)(T node)
{
    if (node.isArray)
        return node.get!(T[]);
    return null;
}

