package main.project.beans;

import java.sql.Timestamp;

public class Booking {
    private int id;
    private String bookingReference;
    private int flightId;
    private int passengerId;
    private String seatNumber;
    private Timestamp bookingDate;
    private double totalAmount;
    private String status;

    // 🔹 Nouveaux champs pour le JSP
    private int aircraftClassSeatId;
    private int childCount;

    // Informations supplémentaires pour l'affichage
    private Flight flight;
    private Passenger passenger;

    public Booking() {}

    public Booking(int id, String bookingReference, int flightId, int passengerId,
                   String seatNumber, Timestamp bookingDate, double totalAmount, String status) {
        this.id = id;
        this.bookingReference = bookingReference;
        this.flightId = flightId;
        this.passengerId = passengerId;
        this.seatNumber = seatNumber;
        this.bookingDate = bookingDate;
        this.totalAmount = totalAmount;
        this.status = status;
    }
    private int babyCount;
    private int adultCount;

public int getBabyCount() { return babyCount; }
public void setBabyCount(int babyCount) { this.babyCount = babyCount; }

public int getAdultCount() { return adultCount; }
public void setAdultCount(int adultCount) { this.adultCount = adultCount; }

    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getBookingReference() { return bookingReference; }
    public void setBookingReference(String bookingReference) { this.bookingReference = bookingReference; }

    public int getFlightId() { return flightId; }
    public void setFlightId(int flightId) { this.flightId = flightId; }

    public int getPassengerId() { return passengerId; }
    public void setPassengerId(int passengerId) { this.passengerId = passengerId; }

    public String getSeatNumber() { return seatNumber; }
    public void setSeatNumber(String seatNumber) { this.seatNumber = seatNumber; }

    public Timestamp getBookingDate() { return bookingDate; }
    public void setBookingDate(Timestamp bookingDate) { this.bookingDate = bookingDate; }

    public double getTotalAmount() { return totalAmount; }
    public void setTotalAmount(double totalAmount) { this.totalAmount = totalAmount; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    // 🔹 Getters / Setters pour les nouveaux champs
    public int getAircraftClassSeatId() { return aircraftClassSeatId; }
    public void setAircraftClassSeatId(int aircraftClassSeatId) { this.aircraftClassSeatId = aircraftClassSeatId; }

    public int getChildCount() { return childCount; }
    public void setChildCount(int childCount) { this.childCount = childCount; }

    public Flight getFlight() { return flight; }
    public void setFlight(Flight flight) { this.flight = flight; }

    public Passenger getPassenger() { return passenger; }
    public void setPassenger(Passenger passenger) { this.passenger = passenger; }
}
