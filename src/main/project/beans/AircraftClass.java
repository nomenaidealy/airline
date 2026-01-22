package main.project.beans;


public class AircraftClass {
    private int id;
    private String libelle;

    public AircraftClass() {}
    public AircraftClass(String libelle) {
        this.libelle = libelle;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getLibelle() { return libelle; }
    public void setLibelle(String libelle) { this.libelle = libelle; }
}
