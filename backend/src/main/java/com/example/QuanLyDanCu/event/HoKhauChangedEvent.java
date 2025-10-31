package com.example.QuanLyDanCu.event;

import lombok.Getter;
import org.springframework.context.ApplicationEvent;

/**
 * Event fired when a HoKhau (Household) is created, updated, or deleted.
 * This event triggers recalculation of fees for the affected household.
 */
@Getter
public class HoKhauChangedEvent extends ApplicationEvent {
    
    private final Long hoKhauId;
    private final ChangeOperation operation;
    
    public HoKhauChangedEvent(Object source, Long hoKhauId, ChangeOperation operation) {
        super(source);
        this.hoKhauId = hoKhauId;
        this.operation = operation;
    }
    
    @Override
    public String toString() {
        return String.format("HoKhauChangedEvent{hoKhauId=%d, operation=%s}", hoKhauId, operation);
    }
}
