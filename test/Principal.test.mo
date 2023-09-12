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

let principal = Principal.fromText("un4fu-tqaaa-aaaab-qadjq-cai");
let defaultAccount : Blob = "\57\4E\66\E1\B5\DD\EF\EA\78\73\6B\E4\6C\4F\61\21\31\98\88\90\08\2E\E8\0F\97\F6\B6\DB\ED\72\84\1E";
let subAccount : Blob = "\4A\8D\3F\2B\6E\01\C8\7D\9E\03\B4\56\7C\F8\9A\01\D2\34\56\78\9A\BC\DE\F0\12\34\56\78\9A\BC\DE\F0";
let accountWithSubAccount : Blob = "\8C\5C\20\C6\15\3F\7F\51\E2\0D\0F\0F\B5\08\51\5B\47\65\63\A9\62\B4\A9\91\5F\4F\02\70\8A\ED\4F\82";

let suite = Suite.suite(
  "Principal",
  [
    Suite.test(
      "toAccount, default sub-account",
      Principal.toLedgerAccount(principal, null),
      M.equals({ BlobTestable and { item = defaultAccount } })
    ),
    Suite.test(
      "toAccount, with sub-account",
      Principal.toLedgerAccount(principal, ?subAccount),
      M.equals({ BlobTestable and { item = accountWithSubAccount } })
    )
  ]
);

Suite.run(suite)
