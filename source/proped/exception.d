/**
 * Exception module
 *
 * Copyright: (c) 2015-2016, Milofon Project.
 * License: Subject to the terms of the BSD license, as written in the included LICENSE.txt file.
 * Authors: Maksim Galanin
 */
module proped.exception;

private
{
    import std.format: format;

    import proped.properties: Properties;
}



/**
 * Loading properties exception
 */
class PropertiesException : Exception
{
    this(string msg, Throwable next = null, string file = __FILE__, size_t line = __LINE__)
    {
        super(msg, file, line, next);
    }
}



/**
 * Manipulate properties exception
 */
class PropertiesNotFoundException : Exception
{
    this(Properties prop, string name, string file = __FILE__, size_t line = __LINE__)
    {
        super("Property '%s' not found (%s)".format(name, prop), file, line, null);
    }
}

