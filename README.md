# MicroChess-Gameplay
This microservice leverages the strengths of the Kubernetes API and the `BEAM VM` (OTP 28+) to provide efficient management 
of real time 1v1 pvp games trough the use of web sockets.

- ♟️ Real time 1v1 pvp chess gameplay

## Architecture
The `BEAM VM`, which is the technology that powers Erlang, Gleam, and of course, Elixir, is a very
powerful tool, which allows difference instances of your programs to communicate between themselves.
In particular, it is possible for two processes (e.g. green threads) to send and receive messages from
one another (In Elixir and similar languaes the programming paradigm is message passing/actor model).

The way this comes in handy is the following: every pod in kubernetes connect and they all form a network
of BEAM VMs. Then, processes that handle socket connections for specific users are spawned on the target 
pods. Every game is managed by a dedicated process, and such process takes in subscriptions by the 
socket handlers and activley notifies them when the game status changes.

```
                 ┌───────┐    ┌─────────────────┐    ┌──────────────────┐
      ┌────────► | POD-0 | ─► | SOCKET PLAYER X | ─► | (X vs Y) PROCESS |
      │          └───────┘    └─────────────────┘    └──────────────────┘
  ┌─────────┐    ┌───────┐                              ↑
─►│ SERVICE │──► | POD-1 |                              |
  └─────────┘    └───────┘                              |
      │          ┌───────┐    ┌─────────────────┐       |
      └────────► | POD-2 | ─► | SOCKET PLAYER Y |───────┘
      |          └───────┘    └─────────────────┘
      │          ┌───────┐
      └────────► | ..... |
                 └───────┘
```

This represents a scalable and effective way of managing shared game-state between different pods, and 
as such is a key tool in the MicroChess platform overall architecture. Keep in mind that processes that
manage game states must write back every move before notifying the subscribers, and they are able to be 
stopped at any time and resume from where they left of due to a mechanism of live-write-back and rehydration.

## Ingress Route Configuration
In order for this to work efficiently, users must connect to the same pod more or less often. Session stickyness
is herby needed, which is the practice of tagging a user session with a cookie and using that cookie to direct
incoming traffik to a given pod based on the cookie. This is easy with `traefik ingress controller`:

```yaml
apiVersion: traefik.io/v1alpha1
kind: IngressRoute
metadata:
  name: microchess-gameplay-ig
  namespace: microchess
spec:
  entryPoints:
    - websecure
  tls:
    secretName: microchess-gameplay-tls
  routes:
    - match: Host(`gameplay.microchess.fdero.com`)
      kind: Rule
      middlewares:
        - name: backend-http-https-redirect
      services:
        - name: microchess-gameplay-sv
          port: 80
          sticky:
            cookie:
              name: microchess-gameplay-sticky
              secure: true
              httpOnly: true
              sameSite: lax
```