package main.project.beans;

public class Society {

    private int id;
    private String libelle;

    public Society() {
    }

    public Society(int id, String libelle) {
        this.id = id;
        this.libelle = libelle;
    }

    // Getters & Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getLibelle() {
        return libelle;
    }

    public void setLibelle(String libelle) {
        this.libelle = libelle;
    }

       @Override
    public String toString() {
        return libelle;
    }
}
