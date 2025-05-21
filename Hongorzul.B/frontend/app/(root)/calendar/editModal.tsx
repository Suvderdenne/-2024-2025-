import React from "react";
import EventModal from "./includes/modal";

interface EventModalProps {
  header: string;
  start: Date;
  end: Date;
  event: any;
  onSave: (eventData: {
    header: string;
    start: Date;
    end: Date;
    customer: string;
    worker: string;
    branch: string;
  }) => void;
  onClose: () => void;
  onDelete: () => void;
}

const EditModal = ({
  header,
  start,
  end,
  onSave,
  onDelete,
  onClose,
  event,
}: EventModalProps) => {
  return (
    <div>
      <EventModal
        header={header}
        start={start}
        end={end}
        onClose={onClose}
        onDelete={onDelete}
        onSave={onSave}
        event={event}
      />
    </div>
  );
};

export default EditModal;
