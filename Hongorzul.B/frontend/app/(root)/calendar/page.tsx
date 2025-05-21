"use client";
import { useEffect, useState } from "react";
import { Button } from "@/components/ui/button"; // Assuming Button component is located in this path
import Link from "next/link"; // Correct import for Link from Next.js
import { fetchCalendars, fetchRoles } from "@/lib/server"; // Adjust the import path
import { CalendarType } from "./columns"; // Assuming Role type exists
import { Calendar, momentLocalizer, Views } from "react-big-calendar";
import {
  Select,
  SelectTrigger,
  SelectValue,
  SelectContent,
  SelectItem,
} from "@/components/ui/select";
import { Label } from "@/components/ui/label";
import { Branch } from "@/app/(root)/branch/columns";

// Import styles for react-big-calendar
import "react-big-calendar/lib/css/react-big-calendar.css";

import moment from "moment";
import AddEventModal, { fetchBranches, fetchWorkers } from "./includes/modal";
import AddModal from "./addModal";
import EditModal from "./editModal";

const localizer = momentLocalizer(moment);

const allViews = Object.keys(Views).map((k) => Views[k]);

const CalendarTable = () => {
  const [data, setData] = useState<CalendarType[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [view, setView] = useState(Views.WEEK);
  const [date, setDate] = useState(new Date());
  const [workers, setWorkers] = useState<Worker[]>([]);
  const [branches, setBranches] = useState<Branch[]>([]);
  const [modalType, setModalType] = useState<string | null>(null);
  const [workerId, setWorkerId] = useState("");

  const [branchId, setBranchId] = useState("");

  const [showModal, setShowModal] = useState(false);
  const [selectedSlot, setSelectedSlot] = useState<{
    start: Date;
    end: Date;
    event_id: string;
    branch: string;
    customer: string;
    worker: string;
    description: string;
  } | null>(null);
  const checkForOverlappingEvent = (start, end, worker_id) => {
    const startMoment = moment(start);
    const endMoment = moment(end);
    debugger;

    return data.find((event) => {
      const eventStart = moment(event.start);
      const eventEnd = moment(event.end);
      return worker_id
        ? startMoment.isBefore(eventEnd) &&
            endMoment.isAfter(eventStart) &&
            event.worker === worker_id
        : startMoment.isBefore(eventEnd) && endMoment.isAfter(eventStart);
    });
  };

  const handleSlotSelect = ({ start, end, worker_id }) => {
    const overlappingEvent = checkForOverlappingEvent(start, end, worker_id);
    if (overlappingEvent) {
      setSelectedSlot({
        ...overlappingEvent,
        start: overlappingEvent.start,
        end: overlappingEvent.end,
        event_id: overlappingEvent.event_id,
      });
      setModalType("edit");
    } else {
      setSelectedSlot({ start, end });
      setModalType("add");
    }
    setShowModal(true);
  };

  const loadData = async () => {
    try {
      const calendars = await fetchCalendars({
        worker: workerId !== "all" ? workerId : "",
        branch: branchId !== "all" ? branchId : "",
      });
      const responseData = [];

      calendars.forEach((calendar) => {
        const start = new Date(calendar.start_time);
        const end = new Date(calendar.end_time);
        responseData.push({
          ...calendar,
          event_id: calendar.event_id,
          start: new Date(
            start?.getFullYear(),
            start.getMonth(),
            start.getDate(),
            start.getHours(),
            start.getMinutes(),
            start.getSeconds()
          ),
          end: new Date(
            end?.getFullYear(),
            end.getMonth(),
            end.getDate(),
            end.getHours(),
            end.getMinutes(),
            end.getSeconds()
          ),
        });
      });
      setData(responseData ?? []);
    } catch (err) {
      setError(err instanceof Error ? err.message : "An error occurred");
    } finally {
      setLoading(false);
    }
  };

  const handleAddEvent = async (eventData: {
    start: Date;
    end: Date;
    customer: string;
    worker: string;
    branch: string;
    service: string;
  }) => {
    try {
      // Call your API to save the event
      const response = await fetch(
        "http://127.0.0.1:8000/calendar-events/create/",
        {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
          },
          body: JSON.stringify({
            start_time: eventData.start.toISOString(),
            end_time: eventData.end.toISOString(),
            customer: eventData.customer,
            worker: eventData.worker,
            branch: eventData.branch,
            service: eventData.service,
          }),
        }
      );

      if (!response.ok) {
        throw new Error("Failed to add event");
      }

      const newEvent = await response.json();

      // Add the new event to the state
      setData((prevData) => [
        ...prevData,
        {
          start: new Date(newEvent.start_time),
          end: new Date(newEvent.end_time),
        },
      ]);

      setShowModal(false); // Close the modal after saving the event
    } catch (err) {
      setError(err instanceof Error ? err.message : "An error occurred");
    }
  };

  const handleEditEvent = async (eventData: {
    event_id: string;
    start: Date;
    end: Date;
    customer: string;
    worker: string;
    branch: string;
    service: string;
  }) => {
    try {
      // Call your API to update the event
      const response = await fetch(
        `http://127.0.0.1:8000/calendar-events/update/${eventData.event_id}/`,
        {
          method: "PUT", // Use PUT for updating an existing event
          headers: {
            "Content-Type": "application/json",
          },
          body: JSON.stringify({
            start_time: eventData.start.toISOString(),
            end_time: eventData.end.toISOString(),
            customer: eventData.customer,
            worker: eventData.worker,
            branch: eventData.branch,
            service: eventData.service,
          }),
        }
      );

      if (!response.ok) {
        throw new Error("Failed to edit event");
      }

      const updatedEvent = await response.json();

      // Update the event in the state
      if (updatedEvent?.status === "success") {
        alert("success");
        setModalType("");
      }
      setData((prevData) =>
        prevData.map((event) =>
          event.id === updatedEvent.data.id
            ? {
                ...event,
                start: new Date(updatedEvent.data.start_time),
                end: new Date(updatedEvent.data.end_time),
              }
            : event
        )
      );

      setShowModal(false); // Close the modal after saving the changes
    } catch (err) {
      setError(err instanceof Error ? err.message : "An error occurred");
    }
  };

  const handleDeleteEvent = async (event_id: string) => {
    try {
      const response = await fetch(
        `http://127.0.0.1:8000/calendar-events/delete/${event_id}/`,
        {
          method: "DELETE",
        }
      );
      if (!response.ok) throw new Error("Failed to delete event");

      loadData();

      // Optionally, update state to remove the deleted event from the UI
    } catch (error) {
      console.error(error);
    }
  };

  console.log("workers", workers);

  useEffect(() => {
    async function fetchData() {
      try {
        const [branchData, workerData] = await Promise.all([
          fetchBranches(),
          fetchWorkers(),
        ]);
        setBranches(branchData);
        setWorkers(workerData);
      } catch (error) {
        console.error(error);
      }
    }
    fetchData();
  }, []);

  useEffect(() => {
    loadData();
  }, [branchId, workerId]);

  useEffect(() => {
    if (workerId === "all") {
      setView(Views.DAY);
    }
  }, [workerId]);

  if (loading) return <div>Loading...</div>;
  if (error) return <div>Error: {error}</div>;

  // Convert roles data into calendar event format

  return (
    <section className="py-24">
      <div className="container ml-32 w-[1000px]">
        <div className="flex items-center justify-between mb-6">
          <h1 className="text-3xl font-bold">Төлөвлөгөө</h1>
        </div>
        {/* Render the calendar component */}
        <div style={{ height: "500px" }}>
          <div className="mb-4">
            <Label htmlFor="worker">Ажилтан</Label>
            <Select onValueChange={setWorkerId} value={workerId}>
              <SelectTrigger>
                <SelectValue placeholder="Ажилтан сонгох" />
              </SelectTrigger>

              <SelectContent>
                <SelectItem key="all-team" value="all">
                  Бүх ажилчид
                </SelectItem>
                {workers.map((wrk) => (
                  <SelectItem key={wrk.worker_id} value={String(wrk.worker_id)}>
                    {wrk.wname + " " + wrk.wfirst}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>

          <div className="mb-4">
            <Label htmlFor="branchId">Салбар</Label>
            <Select onValueChange={setBranchId} value={branchId}>
              <SelectTrigger>
                <SelectValue placeholder="Салбар сонгох" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem key="all-team" value="all">
                  Бүх салбар
                </SelectItem>
                {branches.map((branch) => (
                  <SelectItem
                    key={branch.branch_id}
                    value={String(branch.branch_id)}
                  >
                    {branch.bname}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>
          {workerId === "all" ? (
            workers?.map((worker, index) => {
              // Filter events for the current worker
              const workerEvents = data.filter((row) => {
                return row?.worker === worker?.worker_id;
              });
              return (
                <div key={worker?.worker_id || index} className="mb-8">
                  {/* Worker Name with Icon */}
                  <div className="flex items-center justify-center mb-4">
                    {/* Person Icon */}
                    <svg
                      xmlns="http://www.w3.org/2000/svg"
                      className="h-6 w-6 text-blue-500 mr-2"
                      fill="none"
                      viewBox="0 0 24 24"
                      stroke="currentColor"
                      strokeWidth={2}
                    >
                      <path
                        strokeLinecap="round"
                        strokeLinejoin="round"
                        d="M12 14c1.657 0 3-1.343 3-3s-1.343-3-3-3-3 1.343-3 3 1.343 3 3 3zM6 21v-2c0-2.21 3.582-4 6-4s6 1.79 6 4v2"
                      />
                    </svg>

                    {/* Worker Name */}
                    <h2 className="text-xl font-bold text-center">
                      {worker?.wname}
                    </h2>
                  </div>
                  {workerEvents?.length > 0 && workerEvents && (
                    <Calendar
                      localizer={localizer}
                      events={workerEvents}
                      views={[Views.MONTH, Views.WEEK, Views.DAY]}
                      defaultView={view}
                      view={view}
                      date={date}
                      onView={(view) => setView(view)}
                      onNavigate={(date) => setDate(new Date(date))}
                      onSelectEvent={(event) => {
                        handleSlotSelect({
                          start: event.start,
                          end: event.end,
                          worker_id: worker?.worker_id,
                        });
                      }}
                      onSelectSlot={(slotInfo) => {
                        handleSlotSelect({
                          start: slotInfo.start,
                          end: slotInfo.end,
                          worker_id: worker?.worker_id,
                        });
                      }}
                      selectable={true}
                    />
                  )}
                </div>
              );
            })
          ) : (
            <Calendar
              localizer={localizer}
              events={data}
              views={[Views.MONTH, Views.WEEK, Views.DAY]}
              defaultView={view}
              view={view}
              date={date}
              onView={(view) => setView(view)}
              onNavigate={(date) => setDate(new Date(date))}
              onSelectEvent={handleSlotSelect}
              onSelectSlot={handleSlotSelect}
              selectable={true}
            />
          )}
        </div>

        {showModal && selectedSlot && modalType === "add" && (
          <AddModal
            header={"Цаг бүртгэх"}
            start={selectedSlot.start}
            end={selectedSlot.end}
            onClose={() => setShowModal(false)}
            onSave={handleAddEvent}
          />
        )}

        {selectedSlot && modalType === "edit" && (
          <EditModal
            header={"Бүртгэл засах"}
            start={selectedSlot.start}
            end={selectedSlot.end}
            event={selectedSlot}
            onClose={() => setModalType("")}
            onSave={handleEditEvent} // Assuming handleEditEvent is for editing an existing event
            onDelete={handleDeleteEvent}
          />
        )}
      </div>
    </section>
  );
};

export default CalendarTable;
