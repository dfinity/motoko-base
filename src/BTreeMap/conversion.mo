import Utils "utils";

import Buffer "mo:base/Buffer";
import Nat8 "mo:base/Nat8";
import Nat16 "mo:base/Nat16";
import Nat32 "mo:base/Nat32";
import Nat64 "mo:base/Nat64";
import Char "mo:base/Char";
import Iter "mo:base/Iter";
import Blob "mo:base/Blob";
import Principal "mo:base/Principal";
import List "mo:base/List";
import Text "mo:base/Text";
import Int "mo:base/Int";
import Array "mo:base/Array";

module {

  // Comes from Candy library conversion.mo: https://raw.githubusercontent.com/skilesare/candy_library/main/src/conversion.mo
  
  //////////////////////////////////////////////////////////////////////
  // The following functions converst standard types to Byte arrays
  // From there you can easily get to blobs if necessary with the Blob package
  //////////////////////////////////////////////////////////////////////

  public func nat64ToBytes(x : Nat64) : [Nat8] {
    
    [ Nat8.fromNat(Nat64.toNat((x >> 56) & (255))),
    Nat8.fromNat(Nat64.toNat((x >> 48) & (255))),
    Nat8.fromNat(Nat64.toNat((x >> 40) & (255))),
    Nat8.fromNat(Nat64.toNat((x >> 32) & (255))),
    Nat8.fromNat(Nat64.toNat((x >> 24) & (255))),
    Nat8.fromNat(Nat64.toNat((x >> 16) & (255))),
    Nat8.fromNat(Nat64.toNat((x >> 8) & (255))),
    Nat8.fromNat(Nat64.toNat((x & 255))) ];
  };

  public func nat32ToBytes(x : Nat32) : [Nat8] {
    
    [ Nat8.fromNat(Nat32.toNat((x >> 24) & (255))),
    Nat8.fromNat(Nat32.toNat((x >> 16) & (255))),
    Nat8.fromNat(Nat32.toNat((x >> 8) & (255))),
    Nat8.fromNat(Nat32.toNat((x & 255))) ];
  };

  /// Returns [Nat8] of size 4 of the Nat16
  public func nat16ToBytes(x : Nat16) : [Nat8] {
    
    [ Nat8.fromNat(Nat16.toNat((x >> 8) & (255))),
    Nat8.fromNat(Nat16.toNat((x & 255))) ];
  };

  public func bytesToNat16(bytes: [Nat8]) : Nat16{
    
    (Nat16.fromNat(Nat8.toNat(bytes[0])) << 8) +
    (Nat16.fromNat(Nat8.toNat(bytes[1])));
  };

  public func bytesToNat32(bytes: [Nat8]) : Nat32{
    
    (Nat32.fromNat(Nat8.toNat(bytes[0])) << 24) +
    (Nat32.fromNat(Nat8.toNat(bytes[1])) << 16) +
    (Nat32.fromNat(Nat8.toNat(bytes[2])) << 8) +
    (Nat32.fromNat(Nat8.toNat(bytes[3])));
  };

  public func bytesToNat64(bytes: [Nat8]) : Nat64{
    
    (Nat64.fromNat(Nat8.toNat(bytes[0])) << 56) +
    (Nat64.fromNat(Nat8.toNat(bytes[1])) << 48) +
    (Nat64.fromNat(Nat8.toNat(bytes[2])) << 40) +
    (Nat64.fromNat(Nat8.toNat(bytes[3])) << 32) +
    (Nat64.fromNat(Nat8.toNat(bytes[4])) << 24) +
    (Nat64.fromNat(Nat8.toNat(bytes[5])) << 16) +
    (Nat64.fromNat(Nat8.toNat(bytes[6])) << 8) +
    (Nat64.fromNat(Nat8.toNat(bytes[7])));
  };


  public func natToBytes(n : Nat) : [Nat8] {
    
    var a : Nat8 = 0;
    var b : Nat = n;
    var bytes = List.nil<Nat8>();
    var test = true;
    while test {
      a := Nat8.fromNat(b % 256);
      b := b / 256;
      bytes := List.push<Nat8>(a, bytes);
      test := b > 0;
    };
    List.toArray<Nat8>(bytes);
  };

  public func bytesToNat(bytes : [Nat8]) : Nat {
    
    var n : Nat = 0;
    var i = 0;
    Array.foldRight<Nat8, ()>(bytes, (), func (byte, _) {
      n += Nat8.toNat(byte) * 256 ** i;
      i += 1;
      return;
    });
    return n;
  };

  public func textToByteBuffer(_text : Text) : Buffer.Buffer<Nat8>{
    
    let result : Buffer.Buffer<Nat8> = Buffer.Buffer<Nat8>((_text.size() * 4) +4);
    for(thisChar in _text.chars()){
      for(thisByte in nat32ToBytes(Char.toNat32(thisChar)).vals()){
        result.add(thisByte);
      };
    };
    return result;
  };

  public func textToBytes(_text : Text) : [Nat8]{
    
    return textToByteBuffer(_text).toArray();
  };

  //encodes a string it to a giant int
  public func encodeTextAsNat(phrase : Text) : ?Nat {
    var theSum : Nat = 0;
    Iter.iterate(Text.toIter(phrase), func (x : Char, n : Nat){
      //todo: check for digits
      theSum := theSum + ((Nat32.toNat(Char.toNat32(x)) - 48) * 10 **  (phrase.size()-n-1));
    });
    return ?theSum;
  };

  //conversts "10" to 10
  public func textToNat( txt : Text) : ?Nat {
    if(txt.size() > 0){
      let chars = txt.chars();
      var num : Nat = 0;
      for (v in chars){
        let charToNum = Nat32.toNat(Char.toNat32(v)-48);
        if(charToNum >= 0 and charToNum <= 9){
          num := num * 10 +  charToNum; 
        } else {
          return null;
        };       
      };
      ?num;
    }else {
      return null;
    };
  };

  public func bytesToText(_bytes : [Nat8]) : Text{
    
    var result : Text = "";
    var aChar : [var Nat8] = [var 0, 0, 0, 0];

    for(thisChar in Iter.range(0,_bytes.size())){
      if(thisChar > 0 and thisChar % 4 == 0){
        aChar[0] := _bytes[thisChar-4];
        aChar[1] := _bytes[thisChar-3];
        aChar[2] := _bytes[thisChar-2];
        aChar[3] := _bytes[thisChar-1];
        result := result # Char.toText(Char.fromNat32(bytesToNat32(Array.freeze<Nat8>(aChar))));
      };
    };
    return result;
  };

  public func principalToBytes(_principal: Principal) : [Nat8]{
    
    return Blob.toArray(Principal.toBlob(_principal));
  };

  public func bytesToPrincipal(_bytes: [Nat8]) : Principal{
    
    return Principal.fromBlob(Blob.fromArray(_bytes));
  };

  public func boolToBytes(_bool : Bool) : [Nat8]{
    
    if(_bool == true){
      return [1:Nat8];
    } else {
      return [0:Nat8];
    };
  };

  public func bytesToBool(_bytes : [Nat8]) : Bool{
    
    if(_bytes[0] == 0){
      return false;
    } else {
      return true;
    };
  };

  public func intToBytes(n : Int) : [Nat8]{
    
    var a : Nat8 = 0;
    var c : Nat8 = if(n < 0){1}else{0};
    var b : Nat = Int.abs(n);
    var bytes = List.nil<Nat8>();
    var test = true;
    while test {
      a := Nat8.fromNat(b % 128);
      b := b / 128;
      bytes := List.push<Nat8>(a, bytes);
      test := b > 0;
    };
    let result = Utils.toBuffer<Nat8>([c]);
    result.append(Utils.toBuffer<Nat8>(List.toArray<Nat8>(bytes)));
    result.toArray();
  };

  public func bytesToInt(_bytes : [Nat8]) : Int{
    
    var n : Int = 0;
    var i = 0;
    let natBytes = Array.tabulate<Nat8>(_bytes.size() - 2, func(idx){_bytes[idx+1]});

    Array.foldRight<Nat8, ()>(natBytes, (), func (byte, _) {
      n += Nat8.toNat(byte) * 128 ** i;
      i += 1;
      return;
    });
    if(_bytes[0]==1){
      n *= -1;
    };
    return n;
  };

  public func bytesToNat64Array(array: [Nat8]) : [Nat64] {
    assert(array.size() % 8 == 0);
    let size = array.size() / 8;
    let buffer = Buffer.Buffer<Nat64>(size);
    for (idx in Iter.range(0, size - 1)){
      buffer.add(
        (Nat64.fromNat(Nat8.toNat(array[idx])) << 56) +
        (Nat64.fromNat(Nat8.toNat(array[idx + 1])) << 48) +
        (Nat64.fromNat(Nat8.toNat(array[idx + 2])) << 40) +
        (Nat64.fromNat(Nat8.toNat(array[idx + 3])) << 32) +
        (Nat64.fromNat(Nat8.toNat(array[idx + 4])) << 24) +
        (Nat64.fromNat(Nat8.toNat(array[idx + 5])) << 16) +
        (Nat64.fromNat(Nat8.toNat(array[idx + 6])) << 8) +
        (Nat64.fromNat(Nat8.toNat(array[idx + 7]))));
    };
    buffer.toArray();
  };

  public func nat64ArrayToBytes(array: [Nat64]) : [Nat8] {
    let buffer = Buffer.Buffer<[Nat8]>(array.size() * 8);
    for (nat64 in Array.vals(array)){
      buffer.add(nat64ToBytes(nat64));
    };
    Array.flatten(buffer.toArray());
  };

};