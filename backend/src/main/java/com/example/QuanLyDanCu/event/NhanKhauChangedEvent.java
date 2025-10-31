package com.example.QuanLyDanCu.event;

import lombok.Getter;
import org.springframework.context.ApplicationEvent;

/**
 * Event fired when a NhanKhau (Citizen) is created, updated, or deleted.
 * This event triggers recalculation of fees for the household that the citizen belongs to.
 */
@Getter
public class NhanKhauChangedEvent extends ApplicationEvent {
    
    private final Long nhanKhauId;
    private final Long hoKhauId;
    private final ChangeOperation operation;
    
    public NhanKhauChangedEvent(Object source, Long nhanKhauId, Long hoKhauId, ChangeOperation operation) {
        super(source);
        this.nhanKhauId = nhanKhauId;
        this.hoKhauId = hoKhauId;
        this.operation = operation;
    }
    
    @Override
    public String toString() {
        return String.format("NhanKhauChangedEvent{nhanKhauId=%d, hoKhauId=%d, operation=%s}", 
                             nhanKhauId, hoKhauId, operation);
    }
}
