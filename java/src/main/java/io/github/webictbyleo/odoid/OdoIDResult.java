package io.github.webictbyleo.odoid;

/** Value returned by {@link OdoIDGenerator#next()}. */
public final class OdoIDResult {

    private final String id;
    private final long   n;
    private final int    length;
    private final String namespace;

    public OdoIDResult(String id, long n, int length, String namespace) {
        this.id        = id;
        this.n         = n;
        this.length    = length;
        this.namespace = namespace;
    }

    public String getId()        { return id; }
    public long   getN()         { return n; }
    public int    getLength()    { return length; }
    public String getNamespace() { return namespace; }
}
