; Divine Logic API (c) 2019, Sjshovan (LoTekkie)
; Licensed under BSD 3-Clause (see main file or LICENSE)
; v1.0

ScriptName DivineLogicAPITests extends DivineLogicAPI

; =========================
;         EVENTS
; =========================

event onInit()
    self.setDebug(true)
    info(self + "@ event: onInit | DivineLogicAPITests initialized.", self.showDebug)
    runTests()
endEvent

; =========================
;         METHODS
; =========================

function runTests() 
    info(self + "@ function: runTests | start", self.showDebug)
    bool[] results = new bool[2]
    bool eval = false
    
    ;run tests
    results[0] = self.testRegisterForSignalEvents()


    ;report
    ;info(self + "@ function: runTests | end", self.showDebug)
    ;info(self + "@ function: runTests | report: \r\n" \ 
    ;+ "total tests run: " + results.length + "\r\n" \
    ;+ "results: " + results + "\r\n" \
    ;+ "eval: " + eval \
    ;, self.showDebug)
endFunction    


function testRegisterForSignalEvents()
    
endFunction    