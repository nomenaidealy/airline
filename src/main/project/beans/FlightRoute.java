package main.project.beans;

public class FlightRoute {
    private int id;
    private String flightNumber;
    private int departureAirportId;
    private int arrivalAirportId;

    private Airport departureAirport;
    private Airport arrivalAirport;

    public FlightRoute() {}

    public FlightRoute(int id, String flightNumber, int departureAirportId, int arrivalAirportId) {
        this.id = id;
        this.flightNumber = flightNumber;
        this.departureAirportId = departureAirportId;
        this.arrivalAirportId = arrivalAirportId;
    }

    // Getters & Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getFlightNumber() { return flightNumber; }
    public void setFlightNumber(String flightNumber) { this.flightNumber = flightNumber; }
    public int getDepartureAirportId() { return departureAirportId; }
    public void setDepartureAirportId(int departureAirportId) { this.departureAirportId = departureAirportId; }
    public int getArrivalAirportId() { return arrivalAirportId; }
    public void setArrivalAirportId(int arrivalAirportId) { this.arrivalAirportId = arrivalAirportId; }
    public Airport getDepartureAirport() { return departureAirport; }
    public void setDepartureAirport(Airport departureAirport) { this.departureAirport = departureAirport; }
    public Airport getArrivalAirport() { return arrivalAirport; }
    public void setArrivalAirport(Airport arrivalAirport) { this.arrivalAirport = arrivalAirport; }
}
