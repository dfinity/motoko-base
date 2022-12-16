import Error "mo:base/Error";

import Suite "mo:matchers/Suite";
import T "mo:matchers/Testable";
import M "mo:matchers/Matchers";

let { run; test; suite } = Suite;

class ErrorCodeTestable() : T.Testable<Error.ErrorCode> {
    public func display(code: Error.ErrorCode): Text {
        debug_show(code)
    };
    public func equals(first: Error.ErrorCode, second: Error.ErrorCode): Bool {
        first == second
    }
};

let testMessage = "Test error message";

run(
    suite(
        "reject",
        [
            test(
                "error code",
                Error.code(Error.reject(testMessage)),
                M.equals({{ item = #canister_reject } and ErrorCodeTestable() })
            ),
            test(
                "error message",
                Error.message(Error.reject(testMessage)),
                M.equals(T.text(testMessage))
            ),
        ]
    )
);
