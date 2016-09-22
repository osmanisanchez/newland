class profiles::proxy {
    class{ '::nginx': }
    class{ '::cronmonitor': }
}