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
    import std.algorithm.iteration : map, filter;
    import std.exception : enforceEx;
    import std.file : FileException, readText;
    import std.typecons : Tuple, tuple;
    import std.string : splitLines;
    import std.array : front;
    import std.conv : to;

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
        return toProperties(data);
    }


    private Properties toProperties(string data)
    {
        PropNode[string] map;
        Properties result = Properties(PropNode(map));
        alias Pair = Tuple!(string, "key", string, "value");

        Pair parsePair(string line)
        {
            size_t keyLen;
            char c;
            size_t valueStart = line.length;
            bool hasSep = false;
            bool precedingBackslash = false;
            size_t limit = line.length;

            while (keyLen < limit)
            {
                c = line[keyLen];
                if ((c == '=' || c == ':') && !precedingBackslash)
                {
                    valueStart = keyLen + 1;
                    hasSep = true;
                    break;
                }
                else if ((c == ' ' || c == '\t' || c == '\f') && !precedingBackslash)
                {
                    valueStart = keyLen + 1;
                    break;
                }

                if (c == '\\')
                    precedingBackslash = !precedingBackslash;
                else
                    precedingBackslash = false;

                keyLen++;
            }

            while (valueStart < limit)
            {
                c = line[valueStart];
                if (c != ' ' && c != '\t' && c != '\f')
                {
                    if (!hasSep && (c == '=' || c == ':'))
                        hasSep = true;
                    else
                        break;
                }
                valueStart++;
            }

            return tuple!("key", "value")(line[0..keyLen], line[valueStart..limit]);
        }

        auto pairRange = data.splitLines
            .filter!(l => l.length > 0 && !(l[0] == '#' || l[0] == '!'))
            .map!(parsePair);

        foreach(Pair p; pairRange)
            result.set(p.key, convertValue(p.value));

        return result;
    }


    private PropNode convertValue(string value)
    {
        if (value == "false")
            return PropNode(false);
        else if (value == "true")
            return PropNode(true);
        else if (value == "null")
            return PropNode();
        else
        {
            switch (value.front)
            {
                case '-':
                case '0': .. case '9':
                    bool is_long_overflow;
                    bool is_float;
                    auto num = skipNumber(value, is_float, is_long_overflow);               
                    if (is_float) 
                        return PropNode(to!double(num));
                    else 
                        return PropNode(to!long(num));
                default:
                    return PropNode(value);
            }
        }
    }

    /**
     * Returns the file extension to delermite the type loader
     */
    string[] getExtensions()
    {
        return [".properties"];
    }
}


/**
 * Parse value
 * get from vibe.d 
 */
private string skipNumber(R)(ref R s, out bool is_float, out bool is_long_overflow)
{
    size_t idx = 0;
    is_float = false;
    is_long_overflow = false;
    ulong int_part = 0;
    if (s[idx] == '-') idx++;
    if (s[idx] == '0') idx++;
    else {
        enforceProperties(isDigit(s[idx]), "Digit expected at beginning of number.");
        int_part = s[idx++] - '0';
        while( idx < s.length && isDigit(s[idx]) )
        {
            if (!is_long_overflow)
            {
                auto dig = s[idx] - '0';
                if ((long.max / 10) > int_part || ((long.max / 10) == int_part && (long.max % 10) >= dig))
                {
                    int_part *= 10;
                    int_part += dig;
                }
                else
                {
                    is_long_overflow = true;
                }
            }
            idx++;
        }
    }

    if( idx < s.length && s[idx] == '.' ){
        idx++;
        is_float = true;
        while( idx < s.length && isDigit(s[idx]) ) idx++;
    }

    if( idx < s.length && (s[idx] == 'e' || s[idx] == 'E') ){
        idx++;
        is_float = true;
        if( idx < s.length && (s[idx] == '+' || s[idx] == '-') ) idx++;
        enforceProperties( idx < s.length && isDigit(s[idx]), "Expected exponent." ~ s[0 .. idx]);
        idx++;
        while( idx < s.length && isDigit(s[idx]) ) idx++;
    }

    string ret = s[0 .. idx];
    s = s[idx .. $];
    return ret;
}


private bool isDigit(dchar ch) @safe nothrow pure 
{ 
    return ch >= '0' && ch <= '9'; 
}


private void enforceProperties(string file = __FILE__, size_t line = __LINE__)(bool cond, lazy string message = "Properties exception")
{
	enforceEx!PropertiesParseException(cond, message, file, line);
}


class PropertiesParseException : Exception
{
    this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable next = null)
    {
        super(msg, file, line, next);
    }
}

