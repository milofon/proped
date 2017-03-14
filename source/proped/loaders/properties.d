/**
 * JavaProperties Loader
 *
 * Copyright: (c) 2015-2016, Milofon Project.
 * License: Subject to the terms of the BSD license, as written in the included LICENSE.txt file.
 * Authors: Maksim Galanin
 */
module proped.loaders.properties;

private
{
    import std.file : FileException, readText;

    import proped.properties : Properties, PropNode;
    import proped.loader : PropertiesLoader;
    import proped.exception : PropertiesException;
}


/**
 * The loader data from a .properties file
 *
 * Implements PropertiesLoader
 */
class PropertiesPropertiesLoader : PropertiesLoader
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
        return Properties(PropNode());
    }


    /**
     * Returns the file extension to delermite the type loader
     */
    string[] getExtensions()
    {
        return [".properties"];
    }
}
