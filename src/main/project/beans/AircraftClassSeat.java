package main.project.beans;


public class AircraftClassSeat {
    private int id;
    private int aircraftId;       // référence à Aircraft
    private int aircraftClassId;  // référence à AircraftClass
    private int nombreSeat;

    public AircraftClassSeat() {}
    public AircraftClassSeat(int aircraftId, int aircraftClassId, int nombreSeat) {
        this.aircraftId = aircraftId;
        this.aircraftClassId = aircraftClassId;
        this.nombreSeat = nombreSeat;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getAircraftId() { return aircraftId; }
    public void setAircraftId(int aircraftId) { this.aircraftId = aircraftId; }

    public int getAircraftClassId() { return aircraftClassId; }
    public void setAircraftClassId(int aircraftClassId) { this.aircraftClassId = aircraftClassId; }

    public int getNombreSeat() { return nombreSeat; }
    public void setNombreSeat(int nombreSeat) { this.nombreSeat = nombreSeat; }
}
