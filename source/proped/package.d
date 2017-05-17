/**
 * The package provides the functionaly to loading and manage a collection of properties
 *
 * Copyright: (c) 2015-2016, Milofon Project.
 * License: Subject to the terms of the BSD license, as written in the included LICENSE.txt file.
 * Authors: Maksim Galanin
 */
module proped;


public
{
    version(Have_sdlang_d) 
        import proped.loaders.sdl : SDLPropertiesLoader;
    version(Have_dyaml) 
        import proped.loaders.yaml : YAMLPropertiesLoader;

    import proped.loaders.json : JSONPropertiesLoader;
    import proped.loaders.properties : PropertiesPropertiesLoader;

    import proped.properties : Properties, PropNode;
    import proped.loader : PropertiesLoader, loadProperties, Loader, createPropertiesLoader;
    import proped.exception : PropertiesException, PropertiesNotFoundException;
}

