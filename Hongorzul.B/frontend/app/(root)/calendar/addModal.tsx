import React from "react";
import EventModal from "./includes/modal";

interface EventModalProps {
  header: string;
  start: Date;
  end: Date;
  onSave: (eventData: {
    start: Date;
    end: Date;
    customer: string;
    worker: string;
    branch: string;
  }) => void;
  onClose: () => void;
}

const AddModal = ({ header, start, end, onSave, onClose }: EventModalProps) => {
  return (
    <div>
      <EventModal
        header={header}
        start={start}
        end={end}
        onClose={onClose}
        onSave={onSave}
      />
    </div>
  );
};

export default AddModal;
