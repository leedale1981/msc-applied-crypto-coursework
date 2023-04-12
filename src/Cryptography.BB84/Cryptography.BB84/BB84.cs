using Microsoft.Quantum.Simulation.Simulators;
using Quantum.Cryptography.BB84.Quantum;
using Microsoft.Quantum.Simulation.Core;

namespace Cryptography.BB84;

public class BB84
{
    public static int GetEncryptionKey(int keyLength)
    {
        int ones = 0;

        using QuantumSimulator simulator = new();

        for (int index = 0; index < 1000; index++)
        {
            Result result = GetRandomResult.Run(simulator).Result;

            if (result == Result.One)
            {
                ones++;
            }
        }

        return 1;
    }
}

