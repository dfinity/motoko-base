import Prim "mo:⛔";
import Region "Region";

module {
    public type Index = Nat64;

    public type Buffer = {
        add : (blob : Blob) -> Index;
        addClone : (Index) -> Index;
        get : (Index) -> Blob;
        size : () -> Nat;
        getRep : () -> BufferRep; // for upgrades.
    };

    public class Empty() : Buffer {
        var rep : BufferRep = {
            bytes = Region.new();
            var bytes_count = 0;
            elems = Region.new();
            var elems_count = 0;
        };
        public func add(blob : Blob) : Index {
            bufferAdd(rep, #blob blob)
        };
        public func addClone(index : Index) : Index {
            bufferAdd(rep, #index index)
        };
        public func size() : Nat {
            Prim.nat64ToNat(rep.elems_count)
        };
        public func get(index : Index) : Blob {
            let elem = bufferGetElem(rep, index);
            Region.loadBlob(rep.bytes, elem.pos, Prim.nat64ToNat(elem.size))
        };
        public func getRep() : BufferRep = rep;
    };

    // ## Public representation
    //
    // Exposing representation details permit re-creating the object
    // wrapper after an upgrade.

    public type BufferRep = {
        bytes: Region;
        var bytes_count: Nat64; // more fine-grained than "pages"

        elems: Region;
        var elems_count: Nat64; // more fine-grained than "pages"
    };

    public class FromRep(rep : BufferRep) {
        public func add(blob : Blob) : Index {
            bufferAdd(rep, #blob blob)
        };
        public func addClone(index : Index) : Index {
            bufferAdd(rep, #index index)
        };
        public func size() : Nat {
            Prim.nat64ToNat(rep.elems_count)
        };
        public func get(index : Index) : Blob {
            let elem = bufferGetElem(rep, index);
            Region.loadBlob(rep.bytes, elem.pos, Prim.nat64ToNat(elem.size))
        };
        public func getRep() : BufferRep = rep;
    };

    //
    // ## Implementation details
    //

    type Elem = {
        pos : Nat64;
        size : Nat64;
    };

    let elem_size = 16 : Nat64; /* two Nat64s, for pos and size. */


    func regionEnsureSizeBytes(r : Region, new_byte_count : Nat64) {
        let pages = Region.size(r);
        if (new_byte_count > pages << 16) {
            let new_pages = pages - ((new_byte_count + ((1 << 16) - 1)) / (1 << 16));
            assert Region.grow(r, new_pages) == pages
        }
    };

    func bufferGetElem(self: BufferRep, index: Index) : Elem {
        assert index < self.elems_count;
        let pos = Region.loadNat64(self.elems, index * elem_size);
        let size = Region.loadNat64(self.elems, index * elem_size + 8);
        { pos ; size }
    };

    func bufferAdd(self: BufferRep, thing: { #blob: Blob; #index: Index }) : Index {
        switch thing {
          case (#blob blob) {
                let elem_i = self.elems_count;
                self.elems_count += 1;

                let elem_pos = self.bytes_count;
                self.bytes_count += Prim.natToNat64(blob.size());

                regionEnsureSizeBytes(self.bytes, self.bytes_count);
                Region.storeBlob(self.bytes, elem_pos, blob);

                regionEnsureSizeBytes(self.elems, self.elems_count * elem_size);
                Region.storeNat64(self.elems, elem_i * elem_size + 0, elem_pos);
                Region.storeNat64(self.elems, elem_i * elem_size + 8, Prim.natToNat64(blob.size()));
                elem_i
            };
            case (#index index) {
                let elem = bufferGetElem(self, index);
                let elem_i = self.elems_count;
                self.elems_count += 1;

                regionEnsureSizeBytes(self.elems, self.elems_count * elem_size);
                Region.storeNat64(self.elems, elem_i * elem.size + 0, elem.pos);
                Region.storeNat64(self.elems, elem_i * elem.size + 8, elem.size);
                elem_i
            };
        }
    };


}
