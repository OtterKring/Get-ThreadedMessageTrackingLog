# PS_Get-ThreadedMessageTrackingLog
multi-threaded Exchagne Message Tracking (on premises only!)


Get-MessageTrackingLog on Exchange on-premises can take a really long time if you cannot narrow down the result with the appropriate filter parameters. The more users and the more time you need to cover the worse.

If you do _NOT_ use Exchange Management Shell (which is WinPS only) you can take advantage of Powershell 7's new `foreach -parallel`.

## What is Get-ThreadedMessageTrackingLog doing differently?

By default, when you run `Get-TransportService | Get-MessageTrackingLog` Exchange will tell _ONE_ of you Exchange Servers to query the logs on each server where TransportService is active.

`Get-ThreadedMessageTrackingLog` pipes the result of `Get-TransportService` into a `foreach -parallel` multithreaded loop. Each thread connects to a different server (`$_.name` coming from `Get-TransportService`) and searches only this server. This way all your transport service servers are working together at the same time, delivering your results a lot faster.

*NOTE:* you will most likely not have a performance bonus for small or well filtered searches. `foreach -parallel` and the individual Exchange Session connections take considerable time to build up, so it might even slow you down, if your search is well filtered or doesn't cover a lot of data.

## Requirements

- Powershell 7+
- an already imported Exchange Session
- credentials to pass to the function to be able to import more exchange sessions
