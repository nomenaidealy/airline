package main.project.beans;

public class Aircraft {
    private int id;
    private String registration;
    private String model;
    private int totalSeats;

    public Aircraft() {}

    public Aircraft(int id, String registration, String model, int totalSeats) {
        this.id = id;
        this.registration = registration;
        this.model = model;
        this.totalSeats = totalSeats;
    }

    // Getters and Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getRegistration() {
        return registration;
    }

    public void setRegistration(String registration) {
        this.registration = registration;
    }

    public String getModel() {
        return model;
    }

    public void setModel(String model) {
        this.model = model;
    }

    public int getTotalSeats() {
        return totalSeats;
    }

    public void setTotalSeats(int totalSeats) {
        this.totalSeats = totalSeats;
    }

    @Override
    public String toString() {
        return registration + " - " + model + " (" + totalSeats + " sièges)";
    }
}