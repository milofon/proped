/**
 * YAML Loader
 *
 * Copyright: (c) 2015-2016, Milofon Project.
 * License: Subject to the terms of the BSD license, as written in the included LICENSE.txt file.
 * Authors: Maksim Galanin
 */
module proped.loaders.yaml;

version(Have_dyaml_dlang_tour):

private
{
    import dyaml.loader : Loader;
    import dyaml.node : Node;
    import dyaml.exception : YAMLException;

    import proped.properties : Properties, PropNode;
    import proped.loader : PropertiesLoader;
    import proped.exception : PropertiesException;
}



/**
 * The loader data from a YAML file
 *
 * Implements PropertiesLoader
 */
class YAMLPropertiesLoader : PropertiesLoader
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
        Node root;

        try 
            root = Loader(fileName).load();
        catch(YAMLException e)
            throw new PropertiesException("Error loading properties from a file '" ~ fileName ~ "':", e);

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
        Node root;

        try
            root = Loader((cast(ubyte[])data).dup).load();
        catch(YAMLException e)
            throw new PropertiesException("Error loading properties from a string:", e);

        return toProperties(root);
    }


    private Properties toProperties(Node root)
    {
        PropNode convert(Node node)
        {
            if (!node.isValid)
                return PropNode();
            else if (node.isInt)
                return PropNode(node.get!long);
            else if (node.isFloat)
                return PropNode(node.get!double);
            else if (node.isString)
                return PropNode(node.get!string);
            else if (node.isBool)
                return PropNode(node.get!bool);
            else if (node.isMapping)
            {
                PropNode[string] map;
                foreach(string key, Node value; node)
                    map[key] = convert(value);

                return PropNode(map);
            }
            else if (node.isSequence)
            {
                PropNode[] arr;
                foreach(Node value; node)
                    arr ~= convert(value);

                return PropNode(arr);
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
        return [".yaml", ".yml"];
    }
}

