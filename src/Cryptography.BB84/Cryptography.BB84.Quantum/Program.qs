namespace Quantum.Cryptography.BB84.Quantum {

    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    
    @EntryPoint()
    operation GetRandomPauliZ() : Result {
        use q = Qubit();
        H(q);
        return M(q);
    }

    @EntryPoint()
    operation GetRandomPauliX() : Result {
        use q = Qubit();
        H(q);
        return M(q);
    }
}

