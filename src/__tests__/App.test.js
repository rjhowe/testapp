import React from 'react';
import { screen, render, waitFor } from '@testing-library/react';
import '@testing-library/jest-dom';
import App from '../App';

describe('<App />', () => {
    beforeEach(() => {
        render(<App />);
    });
    test('should show some components without errors', async () => {
        await waitFor(() => {
            expect(screen.getByText('Is anyone there?')).toBeInTheDocument();
        });
    });
});
