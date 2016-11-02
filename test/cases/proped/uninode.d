module cases.proped.uninode;

private
{
    import std.typecons: Nullable;

    import dunit;    

    import proped.uninode;
}

class UnitNodeTest
{
    mixin UnitTest;

    alias TestNode = UniNode!(bool, long, double, string);

    @Test
    void testIsArray()
    {
        TestNode node = TestNode(4L);
        assertFalse(node.isArray);

        node = TestNode([TestNode("one"), TestNode(7L)]);
        assertTrue(node.isArray);
    }

    void testIsObject()
    {
        TestNode node = TestNode(4L);
        assertFalse(node.isObject);

        node = TestNode(["host": TestNode("0.0.0.1"), "port": TestNode(45L)]);
        assertTrue(node.isObject);
    }
    
    @Test
    void testHasNull()
    {
        TestNode node;
        assertTrue(node.hasNull);

        node = TestNode("one");
        assertFalse(node.hasNull);
    }

    @Test
    void testToObject()
    {
        TestNode node = TestNode(4L);
        assertFalse(node.isObject);
        assertNull(node.toObject);

        node = TestNode(["host": TestNode("0.0.0.1"), "port": TestNode(45L)]);
        assertTrue(node.isObject);
        assertNotNull(node.toObject);
    }

    @Test
    void testToArray()
    {
        TestNode node = TestNode(4L);
        assertFalse(node.isArray);
        assertNull(node.toArray);

        node = TestNode([TestNode("one"), TestNode(7L)]);
        assertTrue(node.isArray);
        assertNotNull(node.toArray);
    }
}

