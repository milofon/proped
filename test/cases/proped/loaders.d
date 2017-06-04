module cases.proped.loaders;

private
{
    import dunit;

    import proped;
}


class LoadersTest
{
    mixin UnitTest;

    @Test
    void testLoaderSDL()
    {
        PropertiesLoader loader = new SDLPropertiesLoader();
        Properties config = loader.loadPropertiesFile("test/files/config.sdl");
        testProperties(config);
        testArrayProperties(config);
    }

    @Test
    void testLoaderYAML()
    {
        PropertiesLoader loader = new YAMLPropertiesLoader();
        Properties config = loader.loadPropertiesFile("test/files/config.yml");
        testProperties(config);
        testArrayProperties(config);
    }   

    @Test
    void testLoaderJSON()
    {
        PropertiesLoader loader = new JSONPropertiesLoader();
        Properties config = loader.loadPropertiesFile("test/files/config.json");
        testProperties(config);
        testArrayProperties(config);
    }

    @Test
    void testLoaderProperties()
    {
        PropertiesLoader loader = new PropertiesPropertiesLoader();
        Properties config = loader.loadPropertiesFile("test/files/config.properties");
        testProperties(config);
    }

    void testProperties(Properties config)
    {
        assertTrue("database" in config);
        auto databaseConfigRef = config.sub("database");
        assertFalse(databaseConfigRef.isNull);

        Properties databaseConfig = databaseConfigRef.get;

        assertTrue("database" in databaseConfig);
        assertEquals(databaseConfig.get!string("database"), "test");

        assertTrue("server" in databaseConfig);
        assertEquals(databaseConfig.get!string("server"), "localhost");

        assertTrue("port" in databaseConfig);
        assertEquals(databaseConfig.get!long("port").get, 3050);

        assertTrue("database.username" in config);
        assertEquals(config.get!string("database.username"), "test");
    }

    void testArrayProperties(Properties config)
    {
        assertTrue("service" in config);
        Properties[] services = config.getArray("service");
        assertTrue(services.length > 0);

        Properties oneService = services[0];
        assertTrue("host" in oneService);
        assertFalse(oneService.get!string("host").isNull);
        assertEquals(oneService.get!string("host"), "0.0.0.1");
    }

    @Test
    void testLoadProperties()
    {
        PropertiesLoader[] loaders; 

        loaders ~= new SDLPropertiesLoader();
        loaders ~= new YAMLPropertiesLoader();
        loaders ~= new JSONPropertiesLoader();
        loaders ~= new PropertiesPropertiesLoader();

        loadProperties(loaders, "test/files/config.json");
        loadProperties(loaders, "test/files/config.sdl");
        loadProperties(loaders, "test/files/config.yml");
        loadProperties(loaders, "test/files/config.properties");
    }
}

