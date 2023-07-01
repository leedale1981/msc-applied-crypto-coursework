namespace Cryptography.BB84.Quantum {

    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Random;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    
    @EntryPoint()
    operation RunBB84Example(length: Int): Result {
        Message("Running BB84...");

        // Create qubits for key length
        Message("Creating Qubits with length " + IntAsString(length) + "...");
        use qubits = Qubit[length];

        // Alice creates bits based on random bases.
        Message("Alice encoding bits...");
        let (aliceBases, aliceBitValues) = EncodeBits(qubits);


        // ----------------------------------------------
        // Qubits sent across quantum channel to Bob
        // ----------------------------------------------
        //
        Message("Sending bits across quantum channel...");

        // Eve interferes with the qubits
         Message("Eve interferring with qubits...");
        let (eveBases, eveResult) = Eavesdrop(qubits, 1.0);

        // Bob now selects random basis and measures qubit using either Pauli X or Pauli Z basis.
        Message($"Bob measuring qubits...");
        let (bobBases, bobResults) = GetResults(qubits);

        // Alice and Bobs bases are now compared and the shared values are returned.
        Message("Getting shared basis results...");
        let (sharedValues, sharedResults) = GetSharedResults(aliceBitValues, bobResults, aliceBases, bobBases);

        // We now check for eavesdropping by comparing Alice and Bobs results and determining the percentage of differences.
        Message("Getting percentage difference in results...");
        let (indicesToUse, percentage) = CheckForEavesdropping(sharedValues, sharedResults);  
        Message("Difference " + DoubleAsString(percentage) + "%");
         
        Message("Getting shared key...");
        let key = GetSharedKey(indicesToUse, sharedValues);
        Message("Key length is " + IntAsString(Length(key)));

        return Zero;
    }

    operation GetSharedKey(indicesToUse: Int[], sharedValues: Bool[]) : Bool[] {
        mutable keyBits = [false, size = 0];

        for index in indicesToUse {
            set keyBits += [sharedValues[index]];
        }

        return keyBits;
    }

    operation CheckForEavesdropping(values: Bool[], results: Bool[]) : (Int[], Double) {
        mutable differences = 0;
        mutable indicesToUse = [0, size = 0];

        for index in 0..Length(values) -1{
            if values[index] == results[index] {
                set indicesToUse += [index];
			}
            else {
                set differences += 1;
            }
        }

        return (indicesToUse, (IntAsDouble(differences)/IntAsDouble(Length(values))) * 100.0);
    }
    
    operation EncodeBits(qubits: Qubit[]) : (Bool[], Bool[]) {
        mutable values = [false, size = 0];
        mutable bases = [false, size = 0];

        for qubit in qubits {
            let index = 0;
            // Select a random bit and bases with 50% probabilbity.
            let randomBasis = DrawRandomBool(0.5);
            let randomBit = DrawRandomBool(0.5);

            // If basis = 1 apply the Hardamard transformation to the qubit.
            if randomBasis == true {
                H(qubit);
            }

            // If bit = 1 apply the Pauli X gate to the qubit.
            if randomBit == true {
                X(qubit);
            }

            set bases += [randomBasis];
            set values += [randomBit];
        }

        return (bases, values);
    }
    
    operation GetResults(qubits: Qubit[]) : (Bool[], Bool[]) {
        mutable results = [false, size = 0];
        mutable bases = [false, size = 0];

        for qubit in qubits {
            let index = 0;
            // Select a random bases with 50% probabilbity.
            let randomBasis = DrawRandomBool(0.5);
            set bases += [randomBasis];

            // If Basis = 1 measure with the Pauli X else measure Pauli Z
            let result = Measure([randomBasis ? PauliX | PauliZ], [qubit]);
            set results += [ResultAsBool(result)];
            Reset(qubit);
        }

        return (bases, results);
    }

    operation GetSharedResults(values: Bool[], results: Bool[], bases1: Bool[], bases2: Bool[]) : (Bool[], Bool[]) {
        mutable sharedResults = [false, size = 0];
        mutable sharedValues = [false, size = 0];

        for index in 0..Length(values) -1 {
            if bases1[index] == bases2[index] {
                set sharedValues += [values[index]];
                set sharedResults += [results[index]];
            }
        }

        return (sharedValues, sharedResults);
    }

    operation Eavesdrop(qubits: Qubit[], eavesdropProbability: Double) : (Bool[], Bool[]) {
        mutable results = [false, size = 0];
        mutable bases = [false, size = 0];

        for qubit in qubits {
            let shouldEavesdrop = DrawRandomBool(eavesdropProbability);

            if shouldEavesdrop == true {
                // Select a random bit and bases with 50% probabilbity.
                let randomBasis = DrawRandomBool(0.5);

                // If Basis = 1 measure with the Pauli X else measure Pauli Z
                let result = Measure([randomBasis ? PauliX | PauliZ], [qubit]);
                set results += [ResultAsBool(result)];
            }
		}

        return (bases, results);
    }
}

