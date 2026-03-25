namespace writing_service.Features.Helper;

/// <summary>
/// Circuit breaker states for managing AI call failures.
/// </summary>
public enum CircuitState
{
    Closed,     // Normal operation - all calls pass through
    Open,       // Failing fast - calls rejected immediately
    HalfOpen    // Testing - allowing limited calls to test recovery
}

/// <summary>
/// Circuit breaker implementation to prevent cascade failures in AI calls.
/// </summary>
public class CircuitBreaker
{
    private int _failureCount;
    private int _successCount;
    private DateTime _lastFailureTime = DateTime.MinValue;
    private DateTime _windowStart = DateTime.MinValue;
    private CircuitState _state = CircuitState.Closed;
    private readonly object _lock = new();

    private const int FailureThreshold = 5;
    private const int SuccessThreshold = 3;
    private const int TimeoutSeconds = 30;
    private const int WindowSeconds = 10;

    public CircuitState State
    {
        get
        {
            lock (_lock)
            {
                return _state;
            }
        }
    }

    /// <summary>
    /// Checks if the circuit is open (rejecting calls).
    /// </summary>
    public bool IsOpen => State == CircuitState.Open;

    /// <summary>
    /// Determines if a call can be executed based on circuit state.
    /// </summary>
    /// <returns>True if the call can proceed, false if circuit is open.</returns>
    public bool CanExecute()
    {
        lock (_lock)
        {
            // CLOSED: All calls pass through
            if (_state == CircuitState.Closed)
            {
                return true;
            }

            // OPEN: Check if timeout has elapsed to transition to HalfOpen
            if (_state == CircuitState.Open)
            {
                if ((DateTime.UtcNow - _lastFailureTime).TotalSeconds >= TimeoutSeconds)
                {
                    _state = CircuitState.HalfOpen;
                    _successCount = 0;
                    return true;
                }
                return false;
            }

            // HALF_OPEN: Allow test calls through
            return true;
        }
    }

    /// <summary>
    /// Records a successful call, potentially closing the circuit.
    /// </summary>
    public void RecordSuccess()
    {
        lock (_lock)
        {
            if (_state == CircuitState.HalfOpen)
            {
                _successCount++;
                if (_successCount >= SuccessThreshold)
                {
                    // 3 successes in HalfOpen → CLOSED
                    _state = CircuitState.Closed;
                    _failureCount = 0;
                    _successCount = 0;
                }
            }
            else
            {
                // Reset failure count on success in Closed state
                _failureCount = 0;
            }
        }
    }

    /// <summary>
    /// Records a failed call, potentially opening the circuit.
    /// </summary>
    public void RecordFailure()
    {
        lock (_lock)
        {
            _failureCount++;
            _lastFailureTime = DateTime.UtcNow;

            // Reset window if needed
            if (_state == CircuitState.Closed)
            {
                var now = DateTime.UtcNow;
                if ((now - _windowStart).TotalSeconds > WindowSeconds)
                {
                    // Start new window
                    _windowStart = now;
                    _failureCount = 1;
                }
            }

            if (_state == CircuitState.HalfOpen)
            {
                // 1 failure in HalfOpen → OPEN (restart 30s timer)
                _state = CircuitState.Open;
                _successCount = 0;
            }
            else if (_failureCount >= FailureThreshold)
            {
                // 5 failures in 10 seconds → OPEN
                _state = CircuitState.Open;
            }
        }
    }
}