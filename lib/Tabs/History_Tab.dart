import 'package:flutter/material.dart';
import 'package:skyguardmobileapp/core-api/errors/error_handler.dart';
import 'package:skyguardmobileapp/models/trip_model.dart';
import 'package:skyguardmobileapp/models/accident_model.dart';
import 'package:skyguardmobileapp/services/trips_service.dart';
import 'package:skyguardmobileapp/services/accidents_service.dart';

class HistoryTab extends StatelessWidget {
  const HistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("History"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Trips", icon: Icon(Icons.route)),
              Tab(text: "Accidents", icon: Icon(Icons.warning)),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            TripsTab(),
            AccidentsTab(),
          ],
        ),
      ),
    );
  }
}

class TripsTab extends StatefulWidget {
  const TripsTab({super.key});

  @override
  State<TripsTab> createState() => _TripsTabState();
}

class _TripsTabState extends State<TripsTab> {
  final TripsService tripsService = TripsService();

  bool isLoading = true;
  List<TripModel> trips = [];

  @override
  void initState() {
    super.initState();
    fetchTrips();
  }

  Future<void> fetchTrips() async {
    setState(() {
      isLoading = true;
    });

    try {
      final result = await tripsService.getTrips();

      if (!mounted) return;

      setState(() {
        trips = result;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ErrorHandler.handle(e),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: fetchTrips,
      child: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (trips.isEmpty) {
      return _emptyState();
    }

    return _tripsList();
  }

  Widget _emptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: const [
        SizedBox(height: 180),
        Icon(Icons.route, size: 80, color: Colors.grey),
        SizedBox(height: 16),
        Center(
          child: Text(
            "No trips yet",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
        SizedBox(height: 8),
        Center(
          child: Text(
            "Start driving to see trip history",
            style: TextStyle(color: Colors.grey),
          ),
        ),
      ],
    );
  }

  Widget _tripsList() {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: trips.length,
      itemBuilder: (context, index) {
        final trip = trips[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFFE3F2FD),
              child: Icon(Icons.route, color: Color(0xFF007BA7)),
            ),
            title: Text(
              '${trip.startLocation} → ${trip.endLocation}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              'Distance: ${trip.distance} km\nStatus: ${trip.status}\nStart: ${trip.startTime}',
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }
}

class AccidentsTab extends StatefulWidget {
  const AccidentsTab({super.key});

  @override
  State<AccidentsTab> createState() => _AccidentsTabState();
}

class _AccidentsTabState extends State<AccidentsTab> {
  final AccidentsService accidentsService = AccidentsService();

  bool isLoading = true;
  List<AccidentModel> accidents = [];

  @override
  void initState() {
    super.initState();
    fetchAccidents();
  }

  Future<void> fetchAccidents() async {
    setState(() {
      isLoading = true;
    });

    try {
      final result = await accidentsService.getAccidents();

      if (!mounted) return;

      setState(() {
        accidents = result;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ErrorHandler.handle(e),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: fetchAccidents,
      child: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (accidents.isEmpty) {
      return _emptyState();
    }

    return _accidentsList();
  }

  Widget _emptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: const [
        SizedBox(height: 180),
        Icon(Icons.car_crash, size: 80, color: Colors.grey),
        SizedBox(height: 16),
        Center(
          child: Text(
            "No accidents recorded",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
        SizedBox(height: 8),
        Center(
          child: Text(
            "Your trips are safe so far",
            style: TextStyle(color: Colors.grey),
          ),
        ),
      ],
    );
  }

  Widget _accidentsList() {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: accidents.length,
      itemBuilder: (context, index) {
        final accident = accidents[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFFFFEBEE),
              child: Icon(Icons.car_crash, color: Colors.red),
            ),
            title: Text(
              accident.type,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              'Severity: ${accident.severity}\n'
                  'Location: ${accident.latitude}, ${accident.longitude}\n'
                  'Time: ${accident.timestamp}',
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }
}