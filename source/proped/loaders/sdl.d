/**
 * SDLang Loader
 *
 * Copyright: (c) 2015-2016, Milofon Project.
 * License: Subject to the terms of the BSD license, as written in the included LICENSE.txt file.
 * Authors: Maksim Galanin
 */
module proped.loaders.sdl;

version(Have_sdlang_d):

private
{
    import std.array: empty;

    import sdlang;

    import proped.properties: Properties, PropNode;
    import proped.loader: PropertiesLoader;
    import proped.exception: PropertiesException;
    import proped.uninode: isArray, toArray;
}



/**
 * The loader data from a SDLang file
 *
 * Implements PropertiesLoader
 */
class SDLPropertiesLoader : PropertiesLoader 
{
    /**
     * Loading properties from a file
     *
     * Params:
     *
     * fileName = Path to the file system
     */
    Properties loadPropertiesFile(string fileName)
    {
        Tag root;

        try 
            root = parseFile(fileName);
        catch(ParseException e)
            throw new PropertiesException("Error loading properties from a file '" ~ fileName ~ "': " ~ e.msg, e);

        return toProperties(root);
    }


    /**
     * Loading properties from a string
     *
     * Params:
     *
     * data = Source string
     */
    Properties loadPropertiesString(string data)
    {
        Tag root;

        try
            root = parseSource(data);
        catch(ParseException e)
            throw new PropertiesException("Error loading properties from string: " ~ e.msg, e);

        return toProperties(root);
    }


    private Properties toProperties(Tag root)
    {
        PropNode convertVal(Value val)
        {
            if (val.convertsTo!bool)
                return PropNode(val.get!bool);
            else if (val.convertsTo!long)
                return PropNode(val.get!long);
            else if (val.convertsTo!string)
                return PropNode(val.get!string);
            else if (val.convertsTo!double)
                return PropNode(val.get!double);
            else
                return PropNode();
        }

        PropNode convert(Tag tag)
        {
            if (!tag.tags.empty || !tag.attributes.empty)
            {
                PropNode[string] map;
                if (!tag.values.empty && tag.values[0].convertsTo!string)
                    map["name"] = convertVal(tag.values[0]);

                if (!tag.attributes.empty)
                    foreach(Attribute a; tag.attributes)
                        map[a.name] = convertVal(a.value);

                if (!tag.tags.empty)
                    foreach(Tag sub; tag.tags)
                    {
                        PropNode res = convert(sub);
                        if (!res.hasValue)
                            continue;

                        if (sub.name in map)
                        {
                            PropNode origin = map[sub.name];
                            if (origin.isArray) 
                                map[sub.name] = origin.toArray ~ res;
                            else
                            {
                                PropNode[] arr = [origin, res];
                                map[sub.name] = arr;
                            }
                        }
                        else
                            map[sub.name] = res;
                    }
                return PropNode(map);
            }
            else if (!tag.values.empty)
            {
                return convertVal(tag.values[0]);
            }
            else
                return PropNode(); 
        }

        return Properties(convert(root));
    }


    /**
     * Returns the file extension to delermite the type loader
     */
    string[] getExtensions()
    {
        return [".sdl"];
    }
}

