/**
 * Loader module
 *
 * Copyright: (c) 2015-2016, Milofon Project.
 * License: Subject to the terms of the BSD license, as written in the included LICENSE.txt file.
 * Authors: Maksim Galanin
 */
module proped.loader;

private
{
    import std.path: extension;
    import std.algorithm.searching: canFind;

    import proped.properties: Properties;
    import proped.exception: PropertiesException;
}

 

/**
 * Interface properties loader
 */
interface PropertiesLoader
{
    /**
     * Loading properties from a file
     *
     * Params:
     *
     * fileName = Path to the file system
     */
    Properties loadPropertiesFile(string fileName);


    /**
     * Loading properties from a string
     *
     * Params:
     *
     * data = Source string
     */
    Properties loadPropertiesString(string data);


    /**
     * Returns the file extension to delermite the type loader
     */
    string[] getExtensions();


    /**
     * Checking the possibility to download the file current loader
     *
     * Verification occurs by file extension
     *
     * Params:
     *
     * fileName = File
     */
    final bool isPropertiesFile(string fileName)
    { 
        return canFind(getExtensions(), fileName.extension);
    }
}



/**
 * Loading properties from the file with the necessary loader
 *
 * Params:
 *
 * loaders  = Loaders
 * fileName = Path
 */
Properties loadProperties(PropertiesLoader[] loaders, string fileName)
{
    foreach(PropertiesLoader loader; loaders)
        if (loader.isPropertiesFile(fileName))
            return loader.loadPropertiesFile(fileName);     
    throw new PropertiesException("Not defined loader for " ~ fileName);
}

