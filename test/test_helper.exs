
ExUnit.start()
Testcontainers.start_link()

#------------------------------------------------------------------#
#                       MONGODB TEST SETUP                         #
#------------------------------------------------------------------#

{:ok, _} = Testcontainers.start_container(%Testcontainers.Container{
    image: "mongo:7",
    exposed_ports: [{"27017/tcp", 11011}],
    wait_strategies: [
        Testcontainers.CommandWaitStrategy.new([
            "mongosh", "--eval", "db.adminCommand('ping').ok"
        ])
    ]
})

{:ok, _} = Mongo.start_link(
    name: :mongo_test,
    url: "mongodb://localhost:11011/games_test"
)
