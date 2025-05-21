import { useEffect, useState } from "react";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import {
  Select,
  SelectTrigger,
  SelectValue,
  SelectContent,
  SelectItem,
} from "@/components/ui/select";
import { Autocomplete, TextField } from "@mui/material";
import { fetchServices } from "@/lib/server";
import { debounce } from "lodash";

// Interfaces for prop types
interface EventModalProps {
  header: string;
  start: Date;
  end: Date;
  event: {
    event_id: string;
    start: Date;
    end: Date;
    customer: string;
    worker: string;
    branch: string;
  };
  onSave: (eventData: {
    event_id: string;
    start: Date;
    end: Date;
    customer: string;
    worker: string;
    branch: string;
    service: string;
  }) => void;
  onClose: () => void;
  onDelete: (event_id: string) => void;
}

interface Branch {
  branch_id: number;
  bname: string;
}

interface Customer {
  customer_id: number;
  cname: string;
  cphone: string;
}

interface Worker {
  worker_id: number;
  wfirst: string;
}

// Fetch functions for data
export async function fetchBranches(): Promise<Branch[]> {
  const response = await fetch("http://localhost:8000/branch/");
  if (!response.ok) throw new Error("Failed to fetch branches");
  return response.json();
}

export async function fetchCustomers(): Promise<Customer[]> {
  const response = await fetch("http://localhost:8000/customer/");
  if (!response.ok) throw new Error("Failed to fetch customers");
  return response.json();
}

export async function fetchWorkers(): Promise<Worker[]> {
  const response = await fetch("http://localhost:8000/worker/");
  if (!response.ok) throw new Error("Failed to fetch workers");
  return response.json();
}

const EventModal = ({
  header,
  event,
  start,
  end,
  onSave,
  onDelete,
  onClose,
}: EventModalProps) => {
  const [services, setServices] = useState([]);
  const [branches, setBranches] = useState<Branch[]>([]);
  const [customers, setCustomers] = useState<Customer[]>([]);
  const [workers, setWorkers] = useState<Worker[]>([]);

  const [customerSearch, setCustomerSearch] = useState<Customer | null>(null);
  const [searchPhone, setSearchPhone] = useState("");
  const [currentPage, setCurrentPage] = useState(1);

  const [eventStart, setEventStart] = useState(start);
  const [eventEnd, setEventEnd] = useState(end);

  const [serviceId, setServiceId] = useState(event?.service || "");
  const [customerId, setCustomerId] = useState(event?.customer || "");
  const [workerId, setWorkerId] = useState(event?.worker || "");
  const [branchId, setBranchId] = useState(event?.branch || "");

  // Debounced search for customers
  const handleSearch = debounce(async (query: string) => {
    try {
      const response = await fetch(
        `http://localhost:8000/customer/?page=${currentPage}&phone=${query}`
      );
      if (!response.ok) throw new Error("Failed to fetch customers");
      const data = await response.json();
      setCustomers(data);
    } catch (error) {
      console.error(error);
    }
  }, 300);

  // When phone search input changes
  useEffect(() => {
    handleSearch(searchPhone);
  }, [searchPhone, currentPage]);

  // Handle customer selection
  const handleCustomerSelect = (customer: Customer | null) => {
    if (customer) {
      setCustomerId(String(customer.customer_id));
      setCustomerSearch(customer);
    }
  };

  // Handle event deletion
  const handleDelete = () => {
    onDelete(event.event_id); // Use event_id for deletion
    onClose();
  };

  // Handle form submission
  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    onSave({
      event_id: event?.event_id,
      service: serviceId,
      start: eventStart,
      end: eventEnd,
      customer: customerId,
      worker: workerId,
      branch: branchId,
    });
  };

  // Fetch data for dropdowns
  useEffect(() => {
    async function fetchData() {
      try {
        const [branchData, customerData, workerData, serviceData] =
          await Promise.all([
            fetchBranches(),
            fetchCustomers(),
            fetchWorkers(),
            fetchServices(),
          ]);
        setBranches(branchData);
        setCustomers(customerData);
        setWorkers(workerData);
        setServices(serviceData);
      } catch (error) {
        console.error(error);
      }
    }
    fetchData();
  }, []);

  // Format date for datetime-local input
  const formatDateForInput = (date: Date) => {
    const year = date?.getFullYear();
    const month = String(date?.getMonth() + 1).padStart(2, "0");
    const day = String(date?.getDate()).padStart(2, "0");
    const hours = String(date?.getHours()).padStart(2, "0");
    const minutes = String(date?.getMinutes()).padStart(2, "0");
    return `${year}-${month}-${day}T${hours}:${minutes}`;
  };

  return (
    <div className="fixed inset-0 flex items-center justify-center bg-gray-500 bg-opacity-50 z-50">
      <div className="bg-white rounded-lg shadow-lg w-96 p-6">
        <h2 className="text-2xl font-semibold mb-4">{header}</h2>
        <form onSubmit={handleSubmit}>
          {/* Service Selection */}
          <div className="mb-4">
            <Label htmlFor="service">Үйлчилгээ</Label>
            <Select onValueChange={setServiceId} value={serviceId}>
              <SelectTrigger>
                <SelectValue placeholder="Үйлчилгээ сонгох" />
              </SelectTrigger>
              <SelectContent>
                {services.map((service) => (
                  <SelectItem
                    key={service.service_id}
                    value={String(service.service_id)}
                  >
                    {service.sname}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>

          {/* Start and End Time */}
          <div className="mb-4">
            <Label htmlFor="start">Эхлэх</Label>
            <Input
              type="datetime-local"
              id="start"
              value={formatDateForInput(eventStart)}
              onChange={(e) => setEventStart(new Date(e.target.value))}
            />
          </div>
          <div className="mb-4">
            <Label htmlFor="end">Дуусах</Label>
            <Input
              type="datetime-local"
              id="end"
              value={formatDateForInput(eventEnd)}
              onChange={(e) => setEventEnd(new Date(e.target.value))}
            />
          </div>

          {/* Customer Search (Autocomplete) */}
          <div className="mb-4">
            <Label htmlFor="customer">Үйлчлүүлэгч (Search by Phone)</Label>
            <Autocomplete
              value={customerSearch}
              onChange={(_, newValue) => handleCustomerSelect(newValue)}
              options={customers}
              getOptionLabel={(option) => `${option.cname} (${option.cphone})`}
              renderInput={(params) => (
                <TextField
                  {...params}
                  sx={{
                    "& .MuiInputBase-root": {
                      height: 35,
                      padding: "0 14px",
                    },
                    "& .MuiOutlinedInput-root": {
                      height: "100%",
                    },
                  }}
                />
              )}
              isOptionEqualToValue={(option, value) =>
                option.customer_id === value?.customer_id
              }
            />
          </div>

          {/* Worker and Branch Selection */}
          <div className="mb-4">
            <Label htmlFor="worker">Ажилтан</Label>
            <Select onValueChange={setWorkerId} value={workerId}>
              <SelectTrigger>
                <SelectValue placeholder="Ажилтан сонгох" />
              </SelectTrigger>
              <SelectContent>
                {workers.map((wrk) => (
                  <SelectItem key={wrk.worker_id} value={String(wrk.worker_id)}>
                    {wrk.wfirst}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>
          <div className="mb-4">
            <Label htmlFor="branch">Салбар</Label>
            <Select onValueChange={setBranchId} value={branchId}>
              <SelectTrigger>
                <SelectValue placeholder="Салбар сонгох" />
              </SelectTrigger>
              <SelectContent>
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

          {/* Modal Actions */}
          <div className="flex justify-end space-x-4">
            <button
              type="button"
              onClick={handleDelete}
              className="text-red-500 hover:text-red-700"
            >
              Устгах
            </button>
            <button
              type="submit"
              className="bg-blue-500 text-white px-4 py-2 rounded"
            >
              Хадгалах
            </button>
            <button
              type="button"
              onClick={onClose}
              className="bg-gray-300 text-black px-4 py-2 rounded"
            >
              Буцах
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

export default EventModal;
