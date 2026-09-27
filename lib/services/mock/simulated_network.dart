/// Имитация сетевой задержки, чтобы в прототипе были видны состояния загрузки.
Future<T> simulateNetwork<T>(Duration latency, T Function() compute) =>
    Future<T>.delayed(latency, compute);
