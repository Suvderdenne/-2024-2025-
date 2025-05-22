
import { Input } from "@/components/ui/input";
import { Search as SearchIcon } from "lucide-react";

const Search = () => {
  return (
    <div className="container mx-auto py-8 px-4">
      <div className="mb-8 text-center">
        <h1 className="text-3xl md:text-4xl font-bold mb-2">Хайлт</h1>
        <p className="text-lg text-muted-foreground">
          Та хайж буй хоолны газрыг олно уу
        </p>
      </div>
      
      <div className="max-w-md mx-auto relative">
        <SearchIcon className="absolute left-3 top-1/2 transform -translate-y-1/2 text-muted-foreground h-5 w-5" />
        <Input
          type="text"
          placeholder="Хоолны газар эсвэл хоолны төрлийг оруулна уу..."
          className="pl-10"
        />
      </div>
      
      <div className="mt-10 text-center text-muted-foreground">
        <p>Хайлтын үр дүн энд харагдах болно</p>
      </div>
    </div>
  );
};

export default Search;
