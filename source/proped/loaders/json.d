/**
 * JSON Loader
 *
 * Copyright: (c) 2015-2016, Milofon Project.
 * License: Subject to the terms of the BSD license, as written in the included LICENSE.txt file.
 * Authors: Maksim Galanin
 */
module proped.loaders.json;

version(Have_vibe_d_data):

private
{
    import std.file: FileException, readText;

    import vibe.data.json;

    import proped.properties: Properties, PropNode;
    import proped.loader: PropertiesLoader;
    import proped.exception: PropertiesException;
}



/**
 * The loader data from a JSON file
 *
 * Implements PropertiesLoader
 */
class JSONPropertiesLoader : PropertiesLoader
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
        try 
        {
            string source = readText(fileName);       
            return loadPropertiesString(source);
        }
        catch (FileException e)
            throw new PropertiesException("Error loading properties from a file '" ~ fileName ~ "': " ~ e.msg, e);
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
        Json root;
        try
            root = parseJsonString(data);
        catch (JSONException e)
            throw new PropertiesException("Error loading properties from a string: " ~ e.msg, e);

        return toProperties(root);
    }


    private Properties toProperties(Json root)
    {
        PropNode convert(Json node)
        {
            switch(node.type) with (Json)
            {
                case Type.undefined:
                case Type.null_:
                    return PropNode();
                case Type.bool_:
                    return PropNode(node.get!bool);
                case Type.int_:
                case Type.bigInt:
                    return PropNode(node.get!long);
                case Type.float_:
                    return PropNode(node.get!double);
                case Type.string:
                    return PropNode(node.get!string);
                case Type.array:
                    {
                        PropNode[] arr;
                        foreach(Json ch; node)
                            arr ~= convert(ch);
                        return PropNode(arr);
                    }
                case Type.object:
                    {
                        PropNode[string] map;
                        foreach(string key, Json ch; node)
                            map[key] = convert(ch);

                        return PropNode(map);
                    }
                default:
                    return PropNode();
            }
        }

        return Properties(convert(root));
    }


    /**
     * Returns the file extension to delermite the type loader
     */
    string[] getExtensions()
    {
        return [".json"];
    }
}

