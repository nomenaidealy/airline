package main.project.beans;

import java.sql.Timestamp;
import java.util.Date;

public class FlightInstance {
    private int id;
    private int routeId;
    private int aircraftId;
    private Timestamp departureTime;
    private Timestamp arrivalTime;
    private Date flightDate;
    private double basePrice;
    private String status;

    private FlightRoute route;
    private Aircraft aircraft;

    public FlightInstance() {}

    public FlightInstance(int id, int routeId, int aircraftId, Timestamp departureTime, Timestamp arrivalTime,
                          Date flightDate, double basePrice, String status) {
        this.id = id;
        this.routeId = routeId;
        this.aircraftId = aircraftId;
        this.departureTime = departureTime;
        this.arrivalTime = arrivalTime;
        this.flightDate = flightDate;
        this.basePrice = basePrice;
        this.status = status;
    }

    // Getters & Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public int getRouteId() { return routeId; }
    public void setRouteId(int routeId) { this.routeId = routeId; }
    public int getAircraftId() { return aircraftId; }
    public void setAircraftId(int aircraftId) { this.aircraftId = aircraftId; }
    public Timestamp getDepartureTime() { return departureTime; }
    public void setDepartureTime(Timestamp departureTime) { this.departureTime = departureTime; }
    public Timestamp getArrivalTime() { return arrivalTime; }
    public void setArrivalTime(Timestamp arrivalTime) { this.arrivalTime = arrivalTime; }
    public Date getFlightDate() { return flightDate; }
    public void setFlightDate(Date flightDate) { this.flightDate = flightDate; }
    public double getBasePrice() { return basePrice; }
    public void setBasePrice(double basePrice) { this.basePrice = basePrice; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public FlightRoute getRoute() { return route; }
    public void setRoute(FlightRoute route) { this.route = route; }
    public Aircraft getAircraft() { return aircraft; }
    public void setAircraft(Aircraft aircraft) { this.aircraft = aircraft; }
}
