module cases.proped.properties;

private
{
    import dunit;

    import proped;
}

class PropertiesTest
{
    mixin UnitTest;

    Properties config;
    PropertiesLoader loader;

    @BeforeEach
    void initTest()
    {
        loader = new SDLPropertiesLoader();
        config = loader.loadPropertiesFile("test/files/config.sdl");
    }

    @Test
    void testOperatorIn()
    {
        Properties node = Properties(PropNode(["k": PropNode("v")]));
        assertTrue("k" in node);
    }

    @Test 
    void testOperationAssign()
    {
        Properties node = Properties([PropNode("d"), PropNode("s")]);
        assertEquals(node.length(), 2);
    }
 
    @Test
    void testExists()
    {
        assertFalse("database.database.service" in config);    
        assertTrue("database.database" in config);
        assertFalse("" in config);
    }

    @Test
    void testGet()
    {
        assertTrue(config.get!string("database.database.server").isNull);
        assertFalse(config.get!string("database.server").isNull);
        assertEquals(config.get!string("database.server"), "localhost");
    }

    @Test
    void testGetArray()
    {
        assertTrue("service" in config);
        assertEquals(config.getArray("service").length, 3);
    }
    
    @Test
    void testGetObject()
    {
        assertTrue("services" in config);
        assertEquals(config.getObject("services").length, 2);
    }

    @Test
    void testGetOrElse()
    {
        assertEquals(config.getOrElse("database.database.server", "127.0.0.3"), "127.0.0.3");
        assertEquals(config.getOrElse("database.server", "127.0.0.3"), "localhost");
    }

    @Test
    void testGetProperties()
    {
        auto sub = config.sub("database");
        assertFalse(sub.isNull);
        assertTrue("username" in sub);
    }

    @Test
    void testMerge()
    {
        Properties config2 = loader.loadPropertiesFile("test/files/config-local.sdl");
        assertTrue("database.role" in config2);
        assertEquals(config2.get!string("database.role"), "ADMIN");

        config ~= config2;

        assertTrue("database.role" in config);
        assertEquals(config.get!string("database.role"), "ADMIN");

        assertTrue("service" in config);
        assertTrue(config.getArray("service").length > 3);
    }

    @Test
    void testSet()
    {
        Properties config2 = loader.loadPropertiesFile("test/files/config-local.sdl");
        config2.set("database.port", 40);
        assertEquals(config2.get!long("database.port").get, 40);

        config2.set("database.sub.sub", "127.0.0.1");
        config2.set("data.sub.sub", "127.0.0.1");

        assertFalse(config2.get!string("database.sub.sub").isNull);
        assertEquals(config2.get!string("database.sub.sub"), "127.0.0.1");
        assertEquals(config2.get!string("data.sub.sub"), "127.0.0.1");
    }
}

