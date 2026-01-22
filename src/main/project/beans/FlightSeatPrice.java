package main.project.beans;


import java.math.BigDecimal;

public class FlightSeatPrice {
    private int id;
    private int aircraftClassSeatId; // référence à AircraftClassSeat
    private int flightInstanceId;    // référence à FlightInstance
    private BigDecimal prixBase;

    public FlightSeatPrice() {}
    public FlightSeatPrice(int aircraftClassSeatId, int flightInstanceId, BigDecimal prixBase) {
        this.aircraftClassSeatId = aircraftClassSeatId;
        this.flightInstanceId = flightInstanceId;
        this.prixBase = prixBase;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getAircraftClassSeatId() { return aircraftClassSeatId; }
    public void setAircraftClassSeatId(int aircraftClassSeatId) { this.aircraftClassSeatId = aircraftClassSeatId; }

    public int getFlightInstanceId() { return flightInstanceId; }
    public void setFlightInstanceId(int flightInstanceId) { this.flightInstanceId = flightInstanceId; }

    public BigDecimal getPrixBase() { return prixBase; }
    public void setPrixBase(BigDecimal prixBase) { this.prixBase = prixBase; }
}
