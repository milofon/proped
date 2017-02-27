/**
 * JSON Loader
 *
 * Copyright: (c) 2015-2016, Milofon Project.
 * License: Subject to the terms of the BSD license, as written in the included LICENSE.txt file.
 * Authors: Maksim Galanin
 */
module proped.loaders.json;


private
{
    import std.file : FileException, readText;

    import std.json;

    import proped.properties : Properties, PropNode;
    import proped.loader : PropertiesLoader;
    import proped.exception : PropertiesException;
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
            throw new PropertiesException("Error loading properties from a file '" ~ fileName ~ "':", e);
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
        JSONValue root;
        try
            root = parseJSON(data);
        catch (JSONException e)
            throw new PropertiesException("Error loading properties from a string:", e);

        return toProperties(root);
    }


    private Properties toProperties(JSONValue root)
    {
        PropNode convert(JSONValue node)
        {
            switch(node.type) with (JSON_TYPE)
            {
                case NULL:
                    return PropNode();
                case TRUE:
                    return PropNode(true);
                case FALSE:
                    return PropNode(false);
                case INTEGER:
                case UINTEGER:
                    return PropNode(node.integer);
                case FLOAT:
                    return PropNode(node.floating);
                case STRING:
                    return PropNode(node.str);
                case ARRAY: 
                {
                    PropNode[] arr;
                    foreach(JSONValue ch; node.array)
                        arr ~= convert(ch);
                    return PropNode(arr);
                }
                case OBJECT:
                {
                    PropNode[string] map;
                    foreach(string key, JSONValue ch; node.object)
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

