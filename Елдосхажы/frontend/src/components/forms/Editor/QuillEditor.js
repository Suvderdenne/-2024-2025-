import dynamic from "next/dynamic";
import 'react-quill/dist/quill.snow.css';
const QuillWrapper = dynamic(
    async () => {
        const { default: RQ } = await import('react-quill');
        // eslint-disable-next-line react/display-name
        return ({ ...props }) => <RQ {...props} />;
    },
    {
        ssr: false,
    }
);

const QuillEditor = ({ value, onChange }) => {
    return (
        <QuillWrapper
            value={value}
            onChange={(value) => {
                onChange(value);
            }}
            placeholder="Type here..."
            theme="snow"
        />
    )
};

export default QuillEditor;