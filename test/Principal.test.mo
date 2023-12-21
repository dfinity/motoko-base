import Principal "mo:base/Principal";
import Text "mo:base/Text";
import Blob "mo:base/Blob";
import Suite "mo:matchers/Suite";
import T "mo:matchers/Testable";
import M "mo:matchers/Matchers";

let BlobTestable : T.Testable<Blob> = object {
  public func display(blob : Blob) : Text {
    debug_show blob
  };
  public func equals(blob1 : Blob, blob2 : Blob) : Bool {
    blob1 == blob2
  }
};

let principal1 = Principal.fromText("un4fu-tqaaa-aaaab-qadjq-cai");
let defaultAccount1 : Blob = "\57\4E\66\E1\B5\DD\EF\EA\78\73\6B\E4\6C\4F\61\21\31\98\88\90\08\2E\E8\0F\97\F6\B6\DB\ED\72\84\1E";
let subAccount1 : Blob = "\4A\8D\3F\2B\6E\01\C8\7D\9E\03\B4\56\7C\F8\9A\01\D2\34\56\78\9A\BC\DE\F0\12\34\56\78\9A\BC\DE\F0";
let accountWithSubAccount1 : Blob = "\8C\5C\20\C6\15\3F\7F\51\E2\0D\0F\0F\B5\08\51\5B\47\65\63\A9\62\B4\A9\91\5F\4F\02\70\8A\ED\4F\82";

let principal2 = Principal.fromText("ylia2-w3sds-lgwx6-swrzr-xctdp-2rukx-uothy-yh5te-i5rt6-fqg62-iae");
let defaultAccount2 : Blob = "\CA\04\B1\21\82\A1\6F\55\59\D0\63\BB\F4\46\CB\A2\F8\49\51\FE\1D\13\7C\E7\D7\45\85\1B\B2\96\6E\08";
let subAccount2 : Blob = "\4F\8B\12\A5\C3\E6\07\D9\1F\A2\B0\C4\67\E8\90\23\4A\B6\5D\C8\91\0E\F2\47\8A\CD\56\B3\9E\01\2F\84";
let accountWithSubAccount2 : Blob = "\D4\40\35\AF\5D\1D\6A\37\5F\F6\26\E6\9E\17\FA\44\B3\9C\31\FE\17\D3\3A\54\FF\4C\E4\C6\F0\FA\DA\EC";

let suite = Suite.suite(
  "Principal",
  [
    Suite.test(
      "toLedgerAccount, default sub-account 1",
      Principal.toLedgerAccount(principal1, null),
      M.equals({ BlobTestable and { item = defaultAccount1 } })
    ),
    Suite.test(
      "toLedgerAccount, with sub-account 1",
      Principal.toLedgerAccount(principal1, ?subAccount1),
      M.equals({ BlobTestable and { item = accountWithSubAccount1 } })
    ),
    Suite.test(
      "toAccount, default sub-account 2",
      Principal.toLedgerAccount(principal2, null),
      M.equals({ BlobTestable and { item = defaultAccount2 } })
    ),
    Suite.test(
      "toLedgerAccount, with sub-account 2",
      Principal.toLedgerAccount(principal2, ?subAccount2),
      M.equals({ BlobTestable and { item = accountWithSubAccount2 } })
    )
  ]
);

Suite.run(suite)
