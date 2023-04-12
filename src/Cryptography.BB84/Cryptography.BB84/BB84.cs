using Cryptography.BB84.Quantum;
using Microsoft.Quantum.Simulation.Simulators;

namespace Cryptography.BB84;

public class BB84
{
    public static void Run(int n)
    {
        // Use a quantum computer to get bit values.
        using QuantumSimulator simulator = new();

        // Get 4n random bits.
        int bitLength = n * 4;

        var result = RunBB84Example.Run(simulator, bitLength);

        Console.ReadKey();
    }
}

