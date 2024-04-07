from .agent_based_api.v1 import *


def discover_speedtest_plugin(section):
    yield Service()


def check_speedtest_plugin(section):
    for query in section:
        # SHOW ALL NUMERIC VALUES AS METRIC DATA.
        # (THIS MAKES IT EASIER TO ADD VALUES LATER)
        for value in query:
            try:
                metric_name = value.split("=")[0]
                metric_val = float(value.split("=")[1])
                yield Metric(metric_name, metric_val)
            except:
                # THIS ITEM CANT BE DISPLAYED AS A METRIC
                pass

        try:
            yield Result(
                state=State.OK,
                summary=f"{query[0]} Mbps, {query[1]} Mbps",
                details=f"Ping: {query[2]}, Local IP: {query[3]}, Remote IP: {query[4]}",
            )
        except Exception as e:
            yield Result(
                state=State.CRIT,
                summary="THE SPEED22 TEST DATA COULD NOT BE READ OUT CORRECTLY!",
                details=f"ERROR: {e}",
            )

        return

    yield Result(state=State.CRIT, summary="NO DATA RECORDINGS FOUND!")


register.check_plugin(
    name="ookla_speed_check",
    service_name="Ookla Speed check",
    discovery_function=discover_speedtest_plugin,
    check_function=check_speedtest_plugin,
)
